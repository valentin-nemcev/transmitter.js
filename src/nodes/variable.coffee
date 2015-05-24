'use strict'


RelayNode = require './relay_node'
ValuePayload = require '../payloads/value'


module.exports = class Variable extends RelayNode

  createResponsePayload: ->
    ValuePayload.create(this)


  createRelayPayload: ->
    ValuePayload.create(this)


  createOriginPayload: ->
    ValuePayload.create(this)


  createUpdatePayload: (value) ->
    ValuePayload.createFromValue(value)


  acceptPayload: (payload) ->
    payload.deliverValueState(this)
    return this


  set: (@value) -> this

  get: -> @value
