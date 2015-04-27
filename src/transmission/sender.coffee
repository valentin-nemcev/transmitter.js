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


  createStateMessageWithValue: (value) ->
    payload = StatePayload.createFromValue(value)
    new Message(@transmission, payload)


  createConnectMessage: ->
    payload = ConnectionPayload.createConnect()
    new ConnectionMessage(@transmission, payload)



  queryNodeState: (node) ->
    this.createQuery(directions.forward).sendFromTargetNode(node)


  originate: (node, value) ->
    node.getOriginMessage(this, value).sendFromSourceNode(node)


  updateNodeState: (node, value) ->
    this.createStateMessageWithValue(value).sendToTargetNode(node)


  connect: (connection) ->
    this.createConnectMessage().sendToConnection(connection)
