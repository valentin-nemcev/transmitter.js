'use strict'


Transmitter = require 'transmitter'

class ListItem extends Transmitter.Nodes.Record

  constructor: (@name) ->

  @defineVar 'valueVar'


describe 'Nested list connection', ->

  before ->
    @define 'originList', new Transmitter.Nodes.List()
    @define 'derivedList', new Transmitter.Nodes.List()

    new Transmitter.Channels.ListChannel()
      .withOrigin @originList
      .withMapOrigin (originItem) ->
        new ListItem(originToDerived(originItem.name))
      .withDerived @derivedList
      .withMapDerived (derivedItem) ->
        new ListItem(derivedToOrigin(derivedItem.name))


  specify 'when origin list is updated', ->
    Transmitter.startTransmission (sender) =>
      item1 = new ListItem('Origin item 1')
      item2 = new ListItem('Origin item 2')

      sender.updateNodeState(item1.valueVar, 'Origin value 1')
      sender.updateNodeState(item2.valueVar, 'Origin value 2')
      sender.updateNodeState(@originList, [item1, item2])


  specify 'than update is transmitted to derived list', ->
    derivedItems = @derivedList.getValue()

    expect(derivedItems.map (item) -> item.name)
      .to.equal(['Derived item 1', 'Derived item 2'])
    expect(derivedItems.map (item) -> item.valueVar.getValue())
      .to.equal(['Derived value 1', 'Derived value 2'])
