'use strict'


Binder = require 'binder'


class VariableNode
  Binder.extendWithNodeSource(this)

  Binder.extendWithNodeTarget(this)

  getValue: -> @value

  setValue: (@value) -> this


class TextInput
  Binder.extendWithNodeSource(this)

  Binder.extendWithNodeTarget(this)

  change: (value) ->
    @setValue(value)
    Binder.sendNodeState(this)
    return this

  setValue: (@value) -> this

  getValue: -> @value


describe 'Two-way state message routing', ->

  beforeEach ->
    @tagSet = new VariableNode()
    @tagSet.setValue(new Set())

    @tagSortedList = new VariableNode()
    Binder.buildTwoWayBinding()
      .withOrigin @tagSet
      .withMapOrigin (tags) -> Array.from(tags).sort()
      .withDerived @tagSortedList
      .bind()

    @tagJSON = new VariableNode()
    Binder.buildTwoWayBinding()
      .withOrigin @tagSortedList
      .withMapOrigin (tags) -> JSON.stringify(tags)
      .withDerived @tagJSON
      .withMapDerived (tagJSON) -> JSON.parse(tagJSON)
      .bind()

    @tagInput = new TextInput()
    Binder.buildTwoWayBinding()
      .withOrigin @tagSortedList
      .withMapOrigin (tags) -> tags.join(', ')
      .withDerived @tagInput
      .withMapDerived (tagStr) -> tagStr.split(/\s*,\s*/)
      .bind()


  specify 'when origin node is updated, \
    change is transmitted to derived nodes', ->
    Binder.updateNodeState(@tagSet, new Set(['tagB', 'tagA']))

    expect(@tagJSON.getValue()).to.equal('["tagA","tagB"]')
    expect(@tagInput.getValue()).to.equal('tagA, tagB')
