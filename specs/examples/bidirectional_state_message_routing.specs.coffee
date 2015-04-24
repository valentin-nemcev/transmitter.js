'use strict'


Transmitter = require 'transmitter'


Set::inspect = -> "Set(" + Array.from(this).join(', ') + ")"


describe 'Bidirectional state message routing', ->

  beforeEach ->
    @define 'tagSet', new Transmitter.Nodes.Variable()
    @tagSet.setValue(new Set())

    @define 'tagSortedList', new Transmitter.Nodes.Variable()
    Transmitter.channel()
      .withOrigin @tagSet
      .withMapOrigin (tags) -> Array.from(tags).sort()
      .withDerived @tagSortedList
      .withMapDerived (tags) -> new Set(tags)
      .connect()

    @define 'tagJSON', new Transmitter.Nodes.Variable()
    Transmitter.channel()
      .withOrigin @tagSortedList
      .withMapOrigin (tags) -> JSON.stringify(tags)
      .withDerived @tagJSON
      .withMapDerived (tagJSON) -> tagJSON and JSON.parse(tagJSON)
      .connect()

    @define 'tagInput', new Transmitter.Nodes.Variable()
    Transmitter.channel()
      .withOrigin @tagSortedList
      .withMapOrigin (tags) -> (tags ? []).join(', ')
      .withDerived @tagInput
      .withMapDerived (tagStr) -> tagStr.split(/\s*,\s*/)
      .connect()


  specify 'when derived node is queried, it gets update from origin node', ->
    @tagSet.setValue(new Set(['tagB', 'tagA']))

    Transmitter.queryNodeState(@tagJSON)
    Transmitter.queryNodeState(@tagInput)

    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')


  specify 'when origin node is updated, \
    change is transmitted to derived nodes', ->
    Transmitter.updateNodeState(@tagSet, new Set(['tagB', 'tagA']))

    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')


  specify 'when dervied node is updated, \
    change is transmitted to origin and other derived nodes', ->
    Transmitter.updateNodeState(@tagInput, 'tagA, tagB')

    expect(Array.from(@tagSet.getValue())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')


  specify 'when intermediate node is updated, \
    change is transmitted to origin and derived nodes', ->
    Transmitter.updateNodeState(@tagSet, ['tagA', 'tagB'])

    expect(Array.from(@tagSet.getValue())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')
