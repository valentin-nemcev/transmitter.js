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

    Transmitter.startTransmission (tr) =>
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
        .init(tr)

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
                .withMapDerived (serialized) -> serialized.value
            else
              new Transmitter.Channels.ConstChannel()
                .toTarget @serializedVar
                .inForwardDirection()
                .withPayload ->
                  Transmitter.Payloads.Variable.setConst(
                    {name: null, value: null}
                  )
        .init(tr)

      # TODO
      @nestedVar.init(tr, null)


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
