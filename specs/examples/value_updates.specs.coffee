'use strict'


Transmitter = require 'transmitter'

class StatefulObject

  constructor: (@name) ->


describe 'Value updates preserve identity', ->

  describe 'for variables', ->

    beforeEach ->
      @define 'objectVar', new Transmitter.Nodes.Variable()
      @define 'stringVar', new Transmitter.Nodes.Variable()

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
      @objectVar.set(@object)

      Transmitter.startTransmission (tr) =>
        @stringVar.updateState('nameA', tr)

      expect(@objectVar.get()).to.equal(@object)


  describe 'for lists', ->

    beforeEach ->
      @define 'objectList', new Transmitter.Nodes.List()
      @define 'stringList', new Transmitter.Nodes.List()

      Transmitter.startTransmission (tr) =>
        new Transmitter.Channels.ListChannel()
          .withOrigin @objectList
          .withDerived @stringList
          .withMapOrigin (object) -> object.name
          .withMapDerived (string) -> new StatefulObject(string)
          .withMatchDerivedOrigin (string, object) ->
            object? and string == object.name
          .connect(tr)


    specify 'state change message update target value instead of replacing', ->
      @objectA = new StatefulObject('nameA')
      @objectB = new StatefulObject('nameB')
      @objectList.set([@objectA, @objectB])

      Transmitter.startTransmission (tr) =>
        @stringList.updateState(['nameB', 'nameA'], tr)

      objects = @objectList.get()
      expect(objects[0]).to.equal(@objectB)
      expect(objects[1]).to.equal(@objectA)
