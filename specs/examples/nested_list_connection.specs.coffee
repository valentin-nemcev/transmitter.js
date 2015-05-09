'use strict'


Transmitter = require 'transmitter'
ConnectionPayload = require 'transmitter/payloads/connection'

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
    payload = ConnectionPayload.connect(this)
    @message.sendToConnectionWithPayload(channel, payload)
    return this


  get: -> @channels ? []

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

    @define 'nestedListChannelNode', new NestedListChannelNode()

    Transmitter.startTransmission (tr) =>

      listChannel.connect(tr)

      new Transmitter.Channels.EventChannel()
        .fromSource @originList
        .fromSource @derivedList
        .toConnectionTarget @nestedListChannelNode
        .withTransform (lists) =>
          lists.fetch([@originList, @derivedList]).zip()
            .map ([originItem, derivedItem]) ->
              new Transmitter.Channels.VariableChannel()
                .withOrigin originItem.valueVar
                .withMapOrigin originToDerived
                .withDerived derivedItem.valueVar
                .withMapDerived derivedToOrigin
        .connect(tr)


  specify 'when origin list is updated', ->
    Transmitter.startTransmission (tr) =>
      item1 = new ListItem('Origin item 1')
      item2 = new ListItem('Origin item 2')

      item1.valueVar.updateState('Origin value 1', tr)
      item2.valueVar.updateState('Origin value 2', tr)
      @originList.updateState([item1, item2], tr)


  specify 'then update is transmitted to derived list', ->
    derivedItems = @derivedList.get()

    expect(derivedItems.map (item) -> item.name)
      .to.deep.equal(['Derived item 1', 'Derived item 2'])
    expect(derivedItems.map (item) -> item.valueVar.get())
      .to.deep.equal(['Derived value 1', 'Derived value 2'])
