'use strict'


Transmitter = require 'transmitter'


class VariableNode

  Transmitter.extendWithStatefulNode(this)

  getValue: -> @value

  setValue: (@value) -> this


class StatefulObject

  constructor: (@name, @value = null) ->


describe 'Value updates preserve identity', ->

  beforeEach ->
    @define 'objectVar', new VariableNode()
    @define 'stringVar', new VariableNode()

    Transmitter.channel()
      .withOrigin @objectVar
      .withMapOrigin (object) -> [object.name, object.value].join(':')
      .withUpdateOrigin (object, string) ->
        [name, value] = string.split(',')
        if name == object.name
          object.value = value
          return object
        else
          return new StatefulObject(name, value)
      .withDerived @stringVar
      .connect()


  specify 'state change message update target value instead of replacing', ->
    @object = new StatefulObject('nameA')

    Transmitter.updateNodeState(@stringVar, 'nameA:value1')

    expect(@objectVar.getValue()).to.equal(@object)
    expect(@object.value).to.equal('value1')
