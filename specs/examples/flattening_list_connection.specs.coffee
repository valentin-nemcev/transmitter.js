'use strict'


Transmitter = require 'transmitter'


class NestedObject extends Transmitter.Nodes.Record

  constructor: (@name) ->

  @defineVar 'valueVar'


describe 'Flattening list connection', ->

  class NestedChannel extends Transmitter.Channels.CompositeChannel

    constructor: (@nestedObjects, @serializedVar) ->

    @defineChannel ->
      new Transmitter.Channels.SimpleChannel()
        .inForwardDirection()
        .fromDynamicSources @nestedObjects.map (o) -> o.valueVar
        .toTarget @serializedVar
        .withTransform (valuePayloads) =>
          valuePayloads.merge().map (values) =>
            for value, i in values
              {name: @nestedObjects[i].name, value}


    @defineChannel ->
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource @serializedVar
        .toDynamicTargets @nestedObjects.map (o) -> o.valueVar
        .withTransform (serializedPayload) =>
          serializedPayload
            .map (serialized = []) =>
              serialized[i]?.value for {valueVar}, i in @nestedObjects
            .separate()


  beforeEach ->
    @define 'serializedVar', new Transmitter.Nodes.Variable()
    @define 'nestedList', new Transmitter.Nodes.List()
    @define 'nestedChannelVar', new Transmitter.ChannelNodes.ChannelVariable()

    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .inBackwardDirection()
        .fromSource @serializedVar
        .toTarget @nestedList
        .withTransform (payload) ->
          payload.toSetList().map (serialized) ->
            new NestedObject(serialized.name)
        .init(tr)

    # Separate transmissions to test channel init querying
    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .fromSource @nestedList
        .toConnectionTarget @nestedChannelVar
        .withTransform (nestedList) =>
          nestedList.toSetVariable().map (nested) =>
            new NestedChannel(nested, @serializedVar)
        .init(tr)


  specify 'has default const value after initialization', ->
    expect(@serializedVar.get())
      .to.deep.equal([])


  specify 'creation of nested target after flat source update', ->
    serialized = [
      {name: 'objectA', value: 'value1'}
      {name: 'objectB', value: 'value2'}
    ]

    Transmitter.startTransmission (tr) =>
      @serializedVar.init(tr, serialized)

    nestedObjects = @nestedList.get()
    expect(nestedObjects.length).to.equal(2)
    expect(nestedObjects[0].name).to.equal('objectA')
    expect(nestedObjects[0].valueVar.get()).to.equal('value1')
    expect(nestedObjects[1].name).to.equal('objectB')
    expect(nestedObjects[1].valueVar.get()).to.equal('value2')


  specify 'updating flat target after outer and inner source update', ->
    nestedObjectA = new NestedObject('objectA')
    nestedObjectB = new NestedObject('objectB')

    Transmitter.startTransmission (tr) =>
      nestedObjectA.valueVar.init(tr, 'value1')
      nestedObjectB.valueVar.init(tr, 'value2')
      @nestedList.init(tr, [nestedObjectA, nestedObjectB])

    expect(@serializedVar.get())
      .to.deep.equal([
        {name: 'objectA', value: 'value1'}
        {name: 'objectB', value: 'value2'}
      ])


  specify 'querying flat target after outer source update', ->
    nestedObjectA = new NestedObject('objectA')
    nestedObjectB = new NestedObject('objectB')
    nestedObjectA.valueVar.set('value1')
    nestedObjectB.valueVar.set('value2')
    @nestedList.set([nestedObjectA, nestedObjectB])

    Transmitter.startTransmission (tr) =>
      @serializedVar.queryState(tr)

    expect(@serializedVar.get())
      .to.deep.equal([
        {name: 'objectA', value: 'value1'}
        {name: 'objectB', value: 'value2'}
      ])
