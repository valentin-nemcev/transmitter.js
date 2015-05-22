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


  set: (@value) -> this

  get: -> @value
