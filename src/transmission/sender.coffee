'use strict'


{ConnectionPayload, StatePayload, ValuePayload} = require './payloads'
directions = require '../directions'

Query = require './query'
Message = require './message'
ConnectionMessage = require './connection_message'


module.exports = class Sender

  constructor: (@transmission) ->


  createQuery: (direction) ->
    new Query(@transmission, direction)


  createMessage: (payload) ->
    new Message(@transmission, payload)


  createValueMessage: (value) ->
    payload = ValuePayload.create(value)
    new Message(@transmission, payload)


  createStateMessage: (node) ->
    payload = StatePayload.create(node)
    new Message(@transmission, payload)


  createStateValueMessage: (value) ->
    payload = StatePayload.createFromValue(value)
    new Message(@transmission, payload)


  createConnectMessage: ->
    payload = ConnectionPayload.createConnect()
    new ConnectionMessage(@transmission, payload)



  queryNodeState: (node) ->
    this.createQuery(directions.forward).sendToNodeTarget(node.getNodeTarget())
    return this


  originate: (node, value) ->
    node.originate(value, this)
    return this


  updateNodeState: (node, value) ->
    node.updateState(value, this)
    return this


  connect: (connection) ->
    this.createConnectMessage().sendToConnection(connection)
    return this
