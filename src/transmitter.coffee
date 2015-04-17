'use strict'


assert = require 'assert'

ConnectionBuilder = require './connection/builder'
ChannelBuilder = require './channel_builder'

directions = require './directions'

{ConnectionPayload, ValuePayload, StatePayload} =
  require './transmission/payloads'

Transmission = require './transmission/transmission'
NodeSource = require './connection/node_source'
NodeTarget = require './connection/node_target'


module.exports = new class Transmitter

  constructor: (opts = {}) ->
    {@reverseOrder} = opts


  withLogging: (state, doWithLogging) ->
    if arguments.length is 1
      [state, doWithLogging] = [yes, state]
    Transmission::loggingIsEnabled = state
    doWithLogging()
    Transmission::loggingIsEnabled = no
    return this


  withDifferentTransmissionOrders: (doWithOrder) ->
    doWithOrder(new @constructor(reverseOrder: no), 'straight')
    doWithOrder(new @constructor(reverseOrder: yes), 'reverse')
    return this



  startTransmission: (doWithTransmission) ->
    assert(not @transmission, "Transmissions can't be nested")
    @transmission = new Transmission({@reverseOrder})
    try
      doWithTransmission(@transmission)
      @transmission.respondToQueries()
    finally
      @transmission = null
    return this



  directions: directions


  queryNodeState: (node) ->
    @startTransmission (transmission) =>
      query = transmission.createQuery(@directions.forward)
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


  connect: (connection) ->
    @startTransmission (transmission) =>
      payload = ConnectionPayload.createConnect()
      transmission.createConnectionMessage(payload)
        .sendToConnection(connection)
    return this



  define: (name, value) ->
    value.inspect ?= (-> name)
    @[name] = value
    return value


  extendWithStatefulNode: (cls) ->
    NodeSource.extend(cls)
    NodeTarget.extend(cls)
    cls::createResponsePayload = -> StatePayload.create(this)
    cls::createOriginPayload   = -> StatePayload.create(this)
    cls::createRelayPayload    = -> StatePayload.create(this)
    return this


  extendWithConnectionNode: (cls) ->
    NodeTarget.extend(cls)


  extendWithEventSource: (cls) ->
    NodeSource.extend(cls)
    cls::createResponsePayload = -> ValuePayload.create(null)
    cls::createOriginPayload = (value) -> ValuePayload.create(value)
    return this


  extendWithEventTarget: (cls) ->
    NodeTarget.extend(cls)
    return this



  channel: -> new ChannelBuilder(this)

  connection: -> new ConnectionBuilder(this)
