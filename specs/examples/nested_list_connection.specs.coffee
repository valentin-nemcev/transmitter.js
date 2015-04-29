'use strict'


Transmitter = require 'transmitter'
{ConnectionPayload} = require 'transmitter/transmission/payloads'

class ListItem extends Transmitter.Nodes.Record

  inspect: -> "[#{@name}]"

  constructor: (@name) ->

  @defineVar 'valueVar'


class NestedListChannelNode extends Transmitter.Nodes.ChannelNode

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


  getValue: -> @channels ? []

  setValue: (newChannels) ->
    oldChannels = @channels
    @channels = newChannels

    # oldChannel?.disconnect(@message)
    @connect(newChannel) for newChannel in newChannels
    this



describe 'Nested list connection', ->

  originToDerived = (origin) -> origin.replace('Origin', 'Derived')
  derivedToOrigin = (derived) -> derived.replace('Derived', 'Origin')

  before ->
    @define 'originList', new Transmitter.Nodes.List()
    @define 'derivedList', new Transmitter.Nodes.List()

    listChannel = new Transmitter.Channels.ListChannel()
      .withOrigin @originList
      .withMapOrigin (originItem) ->
        new ListItem(originToDerived(originItem.name))
      .withDerived @derivedList
      .withMapDerived (derivedItem) ->
        new ListItem(derivedToOrigin(derivedItem.name))

    Transmitter.connect(listChannel)

    @define 'nestedListChannelNode', new NestedListChannelNode()

    Transmitter.connection()
      .fromSource @originList
      .fromSource @derivedList
      .toConnectionTarget @nestedListChannelNode
      .withTransform (payload) =>
        origin = payload.get(@originList).getValue()
        derived = payload.get(@derivedList).getValue()
        channels = for originItem, i in origin
          derivedItem = derived[i]
          new Transmitter.Channels.VariableChannel()
            .withOrigin originItem.valueVar
            .withMapOrigin originToDerived
            .withDerived derivedItem.valueVar
            .withMapDerived derivedToOrigin
        payload.replaceWithValue(channels).toState()
      .connect()


  specify 'when origin list is updated', ->
    Transmitter.startTransmission (sender) =>
      item1 = new ListItem('Origin item 1')
      item2 = new ListItem('Origin item 2')

      sender.updateNodeState(item1.valueVar, 'Origin value 1')
      sender.updateNodeState(item2.valueVar, 'Origin value 2')
      sender.updateNodeState(@originList, [item1, item2])


  specify 'then update is transmitted to derived list', ->
    derivedItems = @derivedList.getValue()

    expect(derivedItems.map (item) -> item.name)
      .to.deep.equal(['Derived item 1', 'Derived item 2'])
    expect(derivedItems.map (item) -> item.valueVar.getValue())
      .to.deep.equal(['Derived value 1', 'Derived value 2'])
