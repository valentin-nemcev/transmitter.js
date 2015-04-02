'use strict'


Binder = require 'binder'


class VariableNode

  Binder.extendWithStatefulNode(this)

  getValue: -> @value

  setValue: (@value) -> this


class TextInput

  Binder.extendWithStatefulNode(this)

  change: (value) ->
    @setValue(value)
    Binder.sendNodeState(this)
    return this

  setValue: (@value) -> this

  getValue: -> @value


describe 'Bidirectional state message routing', ->

  beforeEach ->
    @define = (name, value) -> value.inspect ?= (-> name); @[name] = value
    @define 'tagSet', new VariableNode()
    @tagSet.setValue(new Set())

    @define 'tagSortedList', new VariableNode()
    Binder.channel()
      .withOrigin @tagSet
      .withMapOrigin (tags) -> Array.from(tags).sort()
      .withDerived @tagSortedList
      .withMapDerived (tags) -> new Set(tags)
      .connect()

    @define 'tagJSON', new VariableNode()
    Binder.channel()
      .withOrigin @tagSortedList
      .withMapOrigin (tags) -> JSON.stringify(tags)
      .withDerived @tagJSON
      .withMapDerived (tagJSON) -> tagJSON and JSON.parse(tagJSON)
      .connect()

    @define 'tagInput', new TextInput()
    Binder.channel()
      .withOrigin @tagSortedList
      .withMapOrigin (tags) -> (tags ? []).join(', ')
      .withDerived @tagInput
      .withMapDerived (tagStr) -> tagStr.split(/\s*,\s*/)
      .connect()


  specify 'when derived node is queried, it gets update from origin node', ->
    @tagSet.setValue(new Set(['tagB', 'tagA']))

    Binder.queryNodeState(@tagJSON)
    Binder.queryNodeState(@tagInput)

    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')


  specify 'when origin node is updated, \
    change is transmitted to derived nodes', ->
    Binder.updateNodeState(@tagSet, new Set(['tagB', 'tagA']))

    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')


  specify 'when dervied node is updated, \
    change is transmitted to origin and other derived nodes', ->
    Binder.updateNodeState(@tagInput, 'tagA, tagB')

    expect(Array.from(@tagSet.getValue())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')


  specify 'when intermediate node is updated, \
    change is transmitted to origin and derived nodes', ->
    Binder.updateNodeState(@tagSet, ['tagA', 'tagB'])

    expect(Array.from(@tagSet.getValue())).to.deep.equal(['tagA', 'tagB'])
    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')
