'use strict'


ConnectionBuilder = require './connection/builder'
ChannelBuilder = require './channel_builder'

directions = require './directions'

Transmission = require './transmission/transmission'


module.exports = new class Transmitter

  Nodes: require './nodes'
  DOMElement: require './dom_element'

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
    Transmission::reverseOrder = @reverseOrder
    Transmission.start(doWithTransmission)
    return this



  directions: directions


  queryNodeState: (node) ->
    @startTransmission (sender) =>
      sender.createQuery(@directions.forward).sendFromTargetNode(node)


  updateNodeState: (node, value) ->
    @startTransmission (sender) =>
      sender.createStateMessageWithValue(value).sendToTargetNode(node)


  updateNodeStates: (nodeValues...) ->
    @startTransmission (sender) =>
      for [node, value] in nodeValues
        sender.createStateMessageWithValue(value).sendToTargetNode(node)


  originate: (node, value) ->
    @startTransmission (sender) =>
      node.getOriginMessage(sender, value).sendFromSourceNode(node)


  connect: (connection) ->
    @startTransmission (sender) =>
      sender.createConnectMessage().sendToConnection(connection)
    return this



  channel: -> new ChannelBuilder(this)

  connection: -> new ConnectionBuilder(this)
