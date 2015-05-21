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
      new Transmitter.Channels.EventChannel()
        .inBackwardDirection()
        .fromSource @serializedVar
        .toTarget @nestedVar
        .withTransform (payload) ->
          payload.map (serialized, object) ->
            if object? and serialized.name == object.name
              return object
            else
              return new NestedObject(serialized.name)
        .connect(tr)

      new Transmitter.Channels.EventChannel()
        .fromSource @nestedVar
        .toConnectionTarget @nestedChannelVar
        .withTransform (payload) =>
          payload.map((nestedObject) =>
            new Transmitter.Channels.VariableChannel()
              .withOrigin nestedObject.valueVar
              .withMapOrigin (value) -> {name: nestedObject.name, value}
              .withDerived @serializedVar
              .withMapDerived (serialized) -> serialized.value
          ).ifEmpty( =>
            new Transmitter.Channels.ConstChannel()
              .toTarget @serializedVar
              .inForwardDirection()
              .withValue -> null
          )
        .connect(tr)

      # TODO
      @nestedVar.updateState(null, tr)


  specify 'creation of nested target after flat source update', ->
    serialized = {name: 'objectA', value: 'value1'}

    Transmitter.startTransmission (tr) =>
      @serializedVar.updateState(serialized, tr)

    nestedObject = @nestedVar.get()
    expect(nestedObject.name).to.equal('objectA')
    expect(nestedObject.valueVar.get()).to.equal('value1')


  specify 'updating flat target after outer source update', ->
    nestedObject = new NestedObject('objectA')

    Transmitter.startTransmission (tr) =>
      nestedObject.valueVar.updateState('value1', tr)
      @nestedVar.updateState(nestedObject, tr)

    expect(@serializedVar.get())
      .to.deep.equal({name: 'objectA', value: 'value1'})


  specify 'querying flat target after outer source update', ->
    nestedObject = new NestedObject('objectA')
    nestedObject.valueVar.setValue('value1')
    @nestedVar.setValue(nestedObject)

    Transmitter.startTransmission (tr) =>
      @serializedVar.queryState(tr)

    expect(@serializedVar.get())
      .to.deep.equal({name: 'objectA', value: 'value1'})
