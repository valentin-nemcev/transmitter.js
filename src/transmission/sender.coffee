'use strict'


{ConnectionPayload, StatePayload, ValuePayload} = require './payloads'

Query = require './query'
Message = require './message'
ConnectionMessage = require './connection_message'


module.exports = class Sender

  constructor: (@transmission) ->


  createConnectMessage: ->
    payload = ConnectionPayload.createConnect()
    new ConnectionMessage(@transmission, payload)


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


  createQuery: (direction) ->
    new Query(@transmission, direction)
