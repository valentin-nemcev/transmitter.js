'use strict'


Transmitter = require 'transmitter'


Set = require 'collections/set'
Set::inspect = -> "Set(" + this.join(', ') + ")"


describe 'Bidirectional state message routing', ->

  beforeEach ->
    @define 'tagSet', new Transmitter.Nodes.Variable()
    @tagSet.set(new Set())

    @define 'tagSortedList', new Transmitter.Nodes.Variable()
    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @tagSet
        .withMapOrigin (tags) -> tags.sorted()
        .withDerived @tagSortedList
        .withMapDerived (tags) -> new Set(tags)
        .init(tr)

    @define 'tagJSON', new Transmitter.Nodes.Variable()
    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @tagSortedList
        .withMapOrigin (tags) -> JSON.stringify(tags)
        .withDerived @tagJSON
        .withMapDerived (tagJSON) -> tagJSON and JSON.parse(tagJSON)
        .init(tr)

    @define 'tagInput', new Transmitter.Nodes.Variable()
    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @tagSortedList
        .withMapOrigin (tags) -> (tags ? []).join(', ')
        .withDerived @tagInput
        .withMapDerived (tagStr) -> tagStr.split(/\s*,\s*/)
        .init(tr)


  specify 'when derived node is queried, it gets update from origin node', ->
    @tagSet.set(new Set(['tagB', 'tagA']))

    Transmitter.startTransmission (tr) =>
      @tagJSON.queryState(tr)
      @tagInput.queryState(tr)

    expect(@tagJSON.get()).to.equal('["tagA","tagB"]')
    expect(@tagInput.get()).to.equal('tagA, tagB')


  specify 'when origin node is updated, \
    change is transmitted to derived nodes', ->
    Transmitter.startTransmission (tr) =>
      @tagSet.init(tr, new Set(['tagB', 'tagA']))

    expect(@tagJSON.get()).to.equal('["tagA","tagB"]')
    expect(@tagInput.get()).to.equal('tagA, tagB')


  specify 'when derivied node is updated, \
    change is transmitted to origin and other derived nodes', ->
    Transmitter.startTransmission (tr) =>
      @tagInput.init(tr, 'tagA, tagB')

    expect(Array.from(@tagSet.get())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.get()).to.equal('["tagA","tagB"]')


  specify 'when intermediate node is updated, \
    change is transmitted to origin and derived nodes', ->
    Transmitter.startTransmission (tr) =>
      @tagSet.init(tr, ['tagA', 'tagB'])

    expect(Array.from(@tagSet.get())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.get()).to.equal('["tagA","tagB"]')
    expect(@tagInput.get()).to.equal('tagA, tagB')
