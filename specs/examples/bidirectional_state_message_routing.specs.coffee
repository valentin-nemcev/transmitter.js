'use strict'


Transmitter = require 'transmitter'


Set::inspect = -> "Set(" + Array.from(this).join(', ') + ")"


describe 'Bidirectional state message routing', ->

  beforeEach ->
    @define 'tagSet', new Transmitter.Nodes.Variable()
    @tagSet.setValue(new Set())

    @define 'tagSortedList', new Transmitter.Nodes.Variable()
    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @tagSet
        .withMapOrigin (tags) -> Array.from(tags).sort()
        .withDerived @tagSortedList
        .withMapDerived (tags) -> new Set(tags)
        .connect(tr)

    @define 'tagJSON', new Transmitter.Nodes.Variable()
    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @tagSortedList
        .withMapOrigin (tags) -> JSON.stringify(tags)
        .withDerived @tagJSON
        .withMapDerived (tagJSON) -> tagJSON and JSON.parse(tagJSON)
        .connect(tr)

    @define 'tagInput', new Transmitter.Nodes.Variable()
    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @tagSortedList
        .withMapOrigin (tags) -> (tags ? []).join(', ')
        .withDerived @tagInput
        .withMapDerived (tagStr) -> tagStr.split(/\s*,\s*/)
        .connect(tr)


  specify 'when derived node is queried, it gets update from origin node', ->
    @tagSet.setValue(new Set(['tagB', 'tagA']))

    Transmitter.startTransmission (tr) =>
      @tagJSON.queryState(tr)
      @tagInput.queryState(tr)

    expect(@tagJSON.get()).to.equal('["tagA","tagB"]')
    expect(@tagInput.get()).to.equal('tagA, tagB')


  specify 'when origin node is updated, \
    change is transmitted to derived nodes', ->
    Transmitter.startTransmission (tr) =>
      @tagSet.updateState(new Set(['tagB', 'tagA']), tr)

    expect(@tagJSON.get()).to.equal('["tagA","tagB"]')
    expect(@tagInput.get()).to.equal('tagA, tagB')


  specify 'when dervied node is updated, \
    change is transmitted to origin and other derived nodes', ->
    Transmitter.startTransmission (tr) =>
      @tagInput.updateState('tagA, tagB', tr)

    expect(Array.from(@tagSet.get())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.get()).to.equal('["tagA","tagB"]')


  specify 'when intermediate node is updated, \
    change is transmitted to origin and derived nodes', ->
    Transmitter.startTransmission (tr) =>
      @tagSet.updateState(['tagA', 'tagB'], tr)

    expect(Array.from(@tagSet.get())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.get()).to.equal('["tagA","tagB"]')
    expect(@tagInput.get()).to.equal('tagA, tagB')
