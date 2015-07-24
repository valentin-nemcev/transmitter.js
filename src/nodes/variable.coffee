'use strict'


RelayNode = require './relay_node'
VariablePayload = require '../payloads/variable'


module.exports = class Variable extends RelayNode

  payload: VariablePayload


  createResponsePayload: (prevPayload) ->
    @payload.set(this).setPriority(prevPayload?.getPriority() ? 0)


  createOriginPayload: ->
    @payload.set(this).setPriority(1)


  createUpdatePayload: (value) ->
    @payload.setConst(value)


  acceptPayload: (payload) ->
    payload.deliverToVariable(this)
    return this


  set: (@value) -> this

  get: -> @value
