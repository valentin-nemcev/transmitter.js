'use strict'


Transmitter = require 'transmitter'
{ConnectionPayload} = require 'transmitter/transmission/payloads'

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
    payload = ConnectionPayload.createConnect(this)
    @message.sendToConnectionWithPayload(channel, payload)
    return this


  getValue: -> @channel

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

    Transmitter.connection()
      .inDirection(Transmitter.directions.backward)
      .fromSource @serializedVar
      .toTarget @nestedVar
      .withTransform (payload) ->
        payload.mapValue (serialized, object) ->
          if object? and serialized.name == object.name
            return object
          else
            return new NestedObject(serialized.name)
      .connect()

    Transmitter.connection()
      .fromSource @nestedVar
      .toConnectionTarget @nestedChannelVar
      .withTransform (payload) =>
        payload.mapValue (nestedObject) =>
          Transmitter.channel()
            .withOrigin nestedObject?.valueVar
            .withMapOrigin (value) -> {name: nestedObject.name, value}
            .withDerived @serializedVar
            .withMapDerived (serialized) -> serialized.value
      .connect()

    # TODO
    Transmitter.updateNodeState(@nestedVar, null)


  specify 'creation of nested target after flat source update', ->
    serialized = {name: 'objectA', value: 'value1'}

    Transmitter.updateNodeState(@serializedVar, serialized)

    nestedObject = @nestedVar.getValue()
    expect(nestedObject.name).to.equal('objectA')
    expect(nestedObject.valueVar.getValue()).to.equal('value1')


  specify 'updating flat target after outer source update', ->
    nestedObject = new NestedObject('objectA')

    Transmitter.startTransmission (sender) =>
      sender.updateNodeState(nestedObject.valueVar, 'value1')
      sender.updateNodeState(@nestedVar, nestedObject)

    expect(@serializedVar.getValue())
      .to.deep.equal({name: 'objectA', value: 'value1'})


  specify 'querying flat target after outer source update', ->
    nestedObject = new NestedObject('objectA')
    nestedObject.valueVar.setValue('value1')
    @nestedVar.setValue(nestedObject)

    Transmitter.queryNodeState(@serializedVar)

    expect(@serializedVar.getValue())
      .to.deep.equal({name: 'objectA', value: 'value1'})