'use strict'


Transmitter = require 'transmitter'


class ListItem

  inspect: -> "[#{@name}]"

  constructor: (@name) ->
    @valueVar = new Transmitter.Nodes.Variable()



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
      .withOriginDerivedChannel (originItem, derivedItem) ->
        new Transmitter.Channels.VariableChannel()
          .withOrigin originItem.valueVar
          .withMapOrigin originToDerived
          .withDerived derivedItem.valueVar
          .withMapDerived derivedToOrigin

    Transmitter.startTransmission (tr) =>
      listChannel.init(tr)


  specify 'when origin list is updated', ->
    Transmitter.startTransmission (tr) =>
      item1 = new ListItem('Origin item 1')
      item2 = new ListItem('Origin item 2')

      item1.valueVar.init(tr, 'Origin value 1')
      item2.valueVar.init(tr, 'Origin value 2')
      @originList.init(tr, [item1, item2])


  specify 'then update is transmitted to derived list', ->
    derivedItems = @derivedList.get()

    expect(derivedItems.map (item) -> item.name)
      .to.deep.equal(['Derived item 1', 'Derived item 2'])
    expect(derivedItems.map (item) -> item.valueVar.get())
      .to.deep.equal(['Derived value 1', 'Derived value 2'])
