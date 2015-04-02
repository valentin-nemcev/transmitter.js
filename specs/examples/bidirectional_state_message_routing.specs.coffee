'use strict'


Transmitter = require 'transmitter'


class VariableNode

  Transmitter.extendWithStatefulNode(this)

  getValue: -> @value

  setValue: (@value) -> this


class TextInput

  Transmitter.extendWithStatefulNode(this)

  change: (value) ->
    @setValue(value)
    Transmitter.sendNodeState(this)
    return this

  setValue: (@value) -> this

  getValue: -> @value


describe 'Bidirectional state message routing', ->

  beforeEach ->
    @define = (name, value) -> value.inspect ?= (-> name); @[name] = value
    @define 'tagSet', new VariableNode()
    @tagSet.setValue(new Set())

    @define 'tagSortedList', new VariableNode()
    Transmitter.channel()
      .withOrigin @tagSet
      .withMapOrigin (tags) -> Array.from(tags).sort()
      .withDerived @tagSortedList
      .withMapDerived (tags) -> new Set(tags)
      .connect()

    @define 'tagJSON', new VariableNode()
    Transmitter.channel()
      .withOrigin @tagSortedList
      .withMapOrigin (tags) -> JSON.stringify(tags)
      .withDerived @tagJSON
      .withMapDerived (tagJSON) -> tagJSON and JSON.parse(tagJSON)
      .connect()

    @define 'tagInput', new TextInput()
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
