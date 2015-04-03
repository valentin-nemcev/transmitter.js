'use strict'


ConnectionBuilder = require './connection/builder'
ChannelBuilder = require './channel_builder'

{forward, backward} = require './directions'

{ValuePayload, StatePayload} = require './transmission/payloads'

Transmission = require './transmission/transmission'
NodeSource = require './connection/node_source'
NodeTarget = require './connection/node_target'


module.exports = new class Transmitter

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



  queryNodeState: (node) ->
    @startTransmission (transmission) =>
      query = transmission.createQuery(forward)
      query.sendFromTargetNode(node)


  updateNodeState: (node, value) ->
    @startTransmission (transmission) =>
      payload = StatePayload.createFromValue(value)
      transmission.createMessage(payload).sendToTargetNode(node)


  updateNodeStates: (nodeValues...) ->
    @startTransmission (transmission) =>
      for [node, value] in nodeValues
        payload = StatePayload.createFromValue(value)
        transmission.createMessage(payload).sendToTargetNode(node)


  originate: (node, value) ->
    @startTransmission (transmission) =>
      payload = node.createOriginPayload(value)
      transmission.createMessage(payload).sendFromSourceNode(node)



  extendWithStatefulNode: (cls) ->
    NodeSource.extend(cls)
    NodeTarget.extend(cls)
    cls::createResponsePayload = -> StatePayload.create(this)
    cls::createOriginPayload   = -> StatePayload.create(this)
    cls::createRelayPayload    = -> StatePayload.create(this)
    return this


  extendWithEventSource: (cls) ->
    NodeSource.extend(cls)
    cls::createResponsePayload = -> ValuePayload.create(null)
    cls::createOriginPayload = (value) -> ValuePayload.create(value)
    return this


  extendWithEventTarget: (cls) ->
    NodeTarget.extend(cls)
    return this



  channel: -> new ChannelBuilder()

  connection: -> new ConnectionBuilder()
