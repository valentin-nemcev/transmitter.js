'use strict'


Transmitter = require 'transmitter'
ConnectionPayload = require 'transmitter/payloads/connection'

VariableNode = Transmitter.Nodes.Variable
ChannelNode = Transmitter.Nodes.ChannelNode
Record = Transmitter.Nodes.Record


class VariableChannelNode extends ChannelNode

  setSource: (@source) ->

  receiveConnectionMessage: (message) ->
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  receiveMessage: (@message) ->
    @message.getPayload().deliver(this)
    @message = null
    return this


  connect: (channel) ->
    payload = ConnectionPayload.connect(this)
    @message.sendToConnectionWithPayload(channel, payload)
    return this


  get: -> @channel

  setValue: (newChannel) ->
    oldChannel = @channel
    @channel = newChannel

    # oldChannel?.disconnect(@message)
    @connect(newChannel)
    this


class NestedObject extends Record

  constructor: (@name) ->

  @defineVar 'valueVar'


describe 'Flattening connection', ->

  beforeEach ->
    @define 'serializedVar', new VariableNode()
    @define 'nestedVar', new VariableNode()
    @define 'nestedChannelVar', new VariableChannelNode()

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
          payload.map (nestedObject) =>
            new Transmitter.Channels.VariableChannel()
              .withOrigin nestedObject?.valueVar
              .withMapOrigin (value) -> {name: nestedObject.name, value}
              .withDerived @serializedVar
              .withMapDerived (serialized) -> serialized.value
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
