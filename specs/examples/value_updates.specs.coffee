'use strict'


Transmitter = require 'transmitter'

VariableNode = Transmitter.Nodes.Variable

class StatefulObject

  constructor: (@name) ->


describe 'Value updates preserve identity', ->

  beforeEach ->
    @define 'objectVar', new VariableNode()
    @define 'stringVar', new VariableNode()

    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.VariableChannel()
        .withOrigin @objectVar
        .withDerived @stringVar
        .withMapOrigin (object) -> object.name
        .withMapDerived (string) -> new StatefulObject(string)
        .withMatchDerivedOrigin (string, object) ->
          object? and string == object.name
        .connect(tr)


  specify 'state change message update target value instead of replacing', ->
    @object = new StatefulObject('nameA')
    @objectVar.setValue(@object)

    Transmitter.startTransmission (tr) =>
      @stringVar.updateState('nameA', tr)

    expect(@objectVar.get()).to.equal(@object)
