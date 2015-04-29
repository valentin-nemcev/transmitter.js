'use strict'


Transmitter = require 'transmitter'

VariableNode = Transmitter.Nodes.Variable

class StatefulObject

  constructor: (@name, @value = null) ->


describe 'Value updates preserve identity', ->

  beforeEach ->
    @define 'objectVar', new VariableNode()
    @define 'stringVar', new VariableNode()

    new Transmitter.Channels.VariableChannel()
      .withOrigin @objectVar
      .withMapOrigin (object) -> [object.name, object.value].join(':')
      .withUpdateOrigin (string, object) ->
        [name, value] = string.split(':')
        if object? and name == object.name
          object.value = value
          return object
        else
          return new StatefulObject(name, value)
      .withDerived @stringVar
      .connect()


  specify 'state change message update target value instead of replacing', ->
    @object = new StatefulObject('nameA')
    @objectVar.setValue(@object)

    Transmitter.updateNodeState(@stringVar, 'nameA:value1')

    expect(@objectVar.getValue()).to.equal(@object)
    expect(@object.value).to.equal('value1')
