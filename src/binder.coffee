'use strict'


BindingBuilder = require './binding/builder'
ChannelBuilder = require './channel_builder'

{forward, backward} = require './directions'

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
      query = transmission.createQuery(forward)
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


  sendEvent: (from: node) ->
    @startTransmissionWithPayloadFrom(EventPayload.create(), node)


  extendWithStatefulNode: (cls) ->
    NodeSource.extend(cls)
    NodeTarget.extend(cls)
    cls::createResponsePayload = -> StatePayload.create(this)
    return this


  extendWithEventSource: (cls) ->
    NodeSource.extend(cls)
    cls::createResponsePayload = -> EventPayload.createNull()
    return this


  extendWithEventTarget: (cls) ->
    NodeTarget.extend(cls)
    return this


  channel: -> new ChannelBuilder()

  connection: -> new BindingBuilder()
