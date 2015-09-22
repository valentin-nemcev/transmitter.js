'use strict'


RelayNode = require './relay_node'
VariablePayload = require '../payloads/variable'


module.exports = class Variable extends RelayNode

  payload: VariablePayload


  createResponsePayload: (prevPayload) ->
    @payload.set(this)


  createOriginPayload: ->
    @payload.set(this)


  createUpdatePayload: (value) ->
    @payload.setConst(value)


  createPlaceholderPayload: ->
    @payload.setConst(null)


  acceptPayload: (payload) ->
    payload.deliverToVariable(this)
    return this


  set: (@value) -> this

  get: -> @value
