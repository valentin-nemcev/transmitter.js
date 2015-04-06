'use strict'


Transmitter = require 'transmitter'


class VariableNode

  Transmitter.extendWithStatefulNode(this)

  getValue: -> @value

  setValue: (@value) -> this


class VariableChannelNode

  Transmitter.extendWithChannelNode(this)

  getValue: -> @value

  setValue: (@value) -> this


class NestedObject

  define: Transmitter.define

  constructor: (@name) ->
    @define 'valueVar', new VariableNode()


describe 'Flattening connection', ->

  beforeEach ->
    @define 'serializedVar', new VariableNode()
    @define 'nestedVar', new VariableNode()
    @define 'nestedChannelVar', new VariableChannelNode()

    Transmitter.connection()
      .inDirection(Transmitter.directions.backward)
      .fromSource @serializedVar
      .toTarget @nestedVar
      .withTransform (payload) ->
        payload.mapValue (serialized, object) ->
          if object? and serialized.name == object.name
            return object
          else
            return new NestedObject(serialized.name)
      .connect()

    Transmitter.connection()
      .fromSource @nestedVar
      .toTarget @nestedChannelVar
      .withTransform (payload) =>
        payload.mapValue (nestedObject) =>
          Transmitter.channel()
            .withOrigin nestedObject.valueVar
            .withMapOrigin (value) -> {name: nestedObject.name, value}
            .withDerived @serializedVar
            .withMapDerived (serialized) -> serialized.value
            .connect()
      .connect()


  specify 'creation of nested target after flat source update', ->
    serialized = {name: 'objectA', value: 'value1'}

    Transmitter.updateNodeState(@serializedVar, serialized)

    nestedObject = @nestedVar.getValue()
    expect(nestedObject.name).to.equal('objectA')
    expect(nestedObject.valueVar.getValue()).to.equal('value1')


  specify 'updating flat target after outer source update', ->
    nestedObject = new NestedObject('objectA')

    Transmitter.updateNodeStates(
      [nestedObject.valueVar, 'value1']
      [@nestedVar, nestedObject]
    )

    expect(@serializedVar.getValue())
      .to.deep.equal({name: 'objectA', value: 'value1'})


  specify 'querying flat target after outer source update', ->
    nestedObject = new NestedObject('objectA')
    nestedObject.valueVar.setValue('value1')
    @nestedVar.setValue(nestedObject)

    Transmitter.queryNodeState(@serializedVar)

    expect(@serializedVar.getValue())
      .to.deep.equal({name: 'objectA', value: 'value1'})
