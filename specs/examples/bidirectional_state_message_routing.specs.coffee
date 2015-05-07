'use strict'


Transmitter = require 'transmitter'


Set::inspect = -> "Set(" + Array.from(this).join(', ') + ")"


describe 'Bidirectional state message routing', ->

  beforeEach ->
    @define 'tagSet', new Transmitter.Nodes.Variable()
    @tagSet.setValue(new Set())

    @define 'tagSortedList', new Transmitter.Nodes.Variable()
    Transmitter.startTransmission (sender) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @tagSet
        .withMapOrigin (tags) -> Array.from(tags).sort()
        .withDerived @tagSortedList
        .withMapDerived (tags) -> new Set(tags)
        .connect(sender)

    @define 'tagJSON', new Transmitter.Nodes.Variable()
    Transmitter.startTransmission (sender) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @tagSortedList
        .withMapOrigin (tags) -> JSON.stringify(tags)
        .withDerived @tagJSON
        .withMapDerived (tagJSON) -> tagJSON and JSON.parse(tagJSON)
        .connect(sender)

    @define 'tagInput', new Transmitter.Nodes.Variable()
    Transmitter.startTransmission (sender) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @tagSortedList
        .withMapOrigin (tags) -> (tags ? []).join(', ')
        .withDerived @tagInput
        .withMapDerived (tagStr) -> tagStr.split(/\s*,\s*/)
        .connect(sender)


  specify 'when derived node is queried, it gets update from origin node', ->
    @tagSet.setValue(new Set(['tagB', 'tagA']))

    Transmitter.startTransmission (sender) =>
      sender.queryNodeState(@tagJSON)
      sender.queryNodeState(@tagInput)

    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')


  specify 'when origin node is updated, \
    change is transmitted to derived nodes', ->
    Transmitter.startTransmission (sender) =>
      @tagSet.updateState(new Set(['tagB', 'tagA']), sender)

    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')


  specify 'when dervied node is updated, \
    change is transmitted to origin and other derived nodes', ->
    Transmitter.startTransmission (sender) =>
      @tagInput.updateState('tagA, tagB', sender)

    expect(Array.from(@tagSet.getValue())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')


  specify 'when intermediate node is updated, \
    change is transmitted to origin and derived nodes', ->
    Transmitter.startTransmission (sender) =>
      @tagSet.updateState(['tagA', 'tagB'], sender)

    expect(Array.from(@tagSet.getValue())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')
