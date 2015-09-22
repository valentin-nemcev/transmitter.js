'use strict'


Transmitter = require 'transmitter'


class NestedObject extends Transmitter.Nodes.Record

  constructor: (@name) ->

  @defineVar 'valueVar'


describe 'Flattening connection', ->

  beforeEach ->
    @define 'serializedVar', new Transmitter.Nodes.Variable()
    @define 'nestedVar', new Transmitter.Nodes.Variable()
    @define 'nestedChannelVar', new Transmitter.ChannelNodes.ChannelVariable()

    @createBackwardChannel = =>
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource @serializedVar
        .toTarget @nestedVar
        .withTransform (payload) ->
          payload.map (serialized) ->
            if serialized?
              return new NestedObject(serialized.name)
            else
              null

    @createNestedChannel = =>
      new Transmitter.Channels.SimpleChannel()
        .fromSource @nestedVar
        .toConnectionTarget @nestedChannelVar
        .withTransform (payload) =>
          payload.map (nestedObject) =>
            if nestedObject?
              new Transmitter.Channels.VariableChannel()
                .withOrigin nestedObject.valueVar
                .withMapOrigin (value) -> {name: nestedObject.name, value}
                .withDerived @serializedVar
                .withMapDerived (serialized) -> serialized?.value
            else
              new Transmitter.Channels.ConstChannel()
                .toTarget @serializedVar
                .inForwardDirection()
                .withPayload ->
                  Transmitter.Payloads.Variable.setConst(
                    {name: null, value: null}
                  )

  describe 'initialization', ->

    specify 'has default const value after initialization', ->
      Transmitter.startTransmission (tr) =>
        @createBackwardChannel().init(tr)

      # Separate transmissions to test channel init querying
      Transmitter.startTransmission (tr) =>
        @createNestedChannel().init(tr)

      expect(@serializedVar.get())
        .to.deep.equal({name: null, value: null})


  describe 'queries and updates', ->

    beforeEach ->
      Transmitter.startTransmission (tr) =>
        @createBackwardChannel().init(tr)
        @createNestedChannel().init(tr)


    specify 'has default const value after initialization', ->
      expect(@serializedVar.get())
        .to.deep.equal({name: null, value: null})


    specify 'creation of nested target after flat source update', ->
      serialized = {name: 'objectA', value: 'value1'}

      Transmitter.startTransmission (tr) =>
        @serializedVar.init(tr, serialized)

      nestedObject = @nestedVar.get()
      expect(nestedObject.name).to.equal('objectA')
      expect(nestedObject.valueVar.get()).to.equal('value1')


    specify 'updating flat target after outer and inner source update', ->
      nestedObject = new NestedObject('objectA')

      Transmitter.startTransmission (tr) =>
        nestedObject.valueVar.init(tr, 'value1')
        @nestedVar.init(tr, nestedObject)

      expect(@serializedVar.get())
        .to.deep.equal({name: 'objectA', value: 'value1'})


    specify 'updating flat target after outer only source update', ->
      nestedObject = new NestedObject('objectA')
      nestedObject.valueVar.set('value0')
      @serializedVar.set({name: 'objectA', value: 'value1'})

      Transmitter.startTransmission (tr) =>
        @nestedVar.init(tr, nestedObject)

      expect(nestedObject.valueVar.get()).to.deep.equal('value1')


    specify 'querying flat target after outer source update', ->
      nestedObject = new NestedObject('objectA')
      nestedObject.valueVar.set('value1')
      @nestedVar.set(nestedObject)

      Transmitter.startTransmission (tr) =>
        @serializedVar.queryState(tr)

      expect(@serializedVar.get())
        .to.deep.equal({name: 'objectA', value: 'value1'})



  describe 'nesting order', ->

    beforeEach ->
      @define 'serializedDerivedVar', new Transmitter.Nodes.Variable()

      @createDerivedChannel = =>
        new Transmitter.Channels.VariableChannel()
          .withOrigin @serializedVar
          .withDerived @serializedDerivedVar



    ['straight', 'reverse'].forEach (order) ->
      specify "querying source and target \
          results in correct response order (#{order})", ->

        Transmitter.startTransmission (tr) =>
          tr.reverseOrder = order is 'reverse'
          @createBackwardChannel().init(tr)
          @createNestedChannel().init(tr)
          @createDerivedChannel().init(tr)

          nestedObject = new NestedObject('objectA')
          nestedObject.valueVar.init(tr, 'value1')
          @nestedVar.init(tr, nestedObject)

        expect(@serializedDerivedVar.get())
          .to.deep.equal({name: 'objectA', value: 'value1'})
