'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
TwoWayBindingBuilder = require './complex_bindings/two_way_binding_builder'

{forward, backward} = require './binding/directions'

{EventPayload, ValuePayload, StatePayload} = require './transmission/payloads'

Transmission = require './transmission/transmission'
NodeSource = require './binding/node_source'
NodeTarget = require './binding/node_target'


module.exports = new class Binder

  constructor: (opts = {}) ->
    {@reverseOrder} = opts


  withDifferentTransmissionOrders: (doWithOrder) ->
    doWithOrder(new @constructor(reverseOrder: no), 'straight')
    doWithOrder(new @constructor(reverseOrder: yes), 'reverse')
    return this


  startTransmission: (doWithTransmission) ->
    transmission = new Transmission({@reverseOrder})
    doWithTransmission(transmission)
    transmission.respondToQueries()
    return this


  startTransmissionWithPayloadFrom: (payload, node) ->
    @startTransmission (transmission) =>
      message = transmission.createMessage(payload)
      message.sendFromSourceNode(node)


  queryNodeState: (node) ->
    @startTransmission (transmission) =>
      query = transmission.createQuery(StatePayload.create, forward)
      query.sendFromTargetNode(node)


  updateNodeState: (node, value) ->
    payload = StatePayload.updateNodeAndCreate(node, value)
    @startTransmissionWithPayloadFrom(payload, node)


  updateNodesState: (nodeValues...) ->
    @startTransmission (transmission) =>
      for [node, value] in nodeValues
        payload = StatePayload.updateNodeAndCreate(node, value)
        transmission.createMessage(payload).sendFromSourceNode(node)


  sendNodeState: (node) ->
    @startTransmissionWithPayloadFrom(new StatePayload(node), node)


  sendValue: (value, from: node) ->
    @startTransmissionWithPayloadFrom(new ValuePayload(value), node)


  # TODO rename to sendEvent
  sendBare: (from: node) ->
    @startTransmissionWithPayloadFrom(new EventPayload(), node)


  extendWithNodeSource: (cls) ->
    NodeSource.extend(cls)
    return this


  extendWithNodeTarget: (cls) ->
    NodeTarget.extend(cls)
    return this


  buildTwoWayBinding: -> new TwoWayBindingBuilder(this)

  buildOneWayBinding: -> new OneWayBindingBuilder()

  buildCompositeSource: -> new CompositeSourceBuilder()

  bind: (binding) -> binding.bind()
