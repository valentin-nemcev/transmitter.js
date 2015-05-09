'use strict'


NodeTarget = require '../connection/node_target'

{ValuePayload} = require '../transmission/payloads'


module.exports = class EventTarget

  NodeTarget.extend this

  routeMessage: (payload, tr) ->
    payload.deliverToEventTarget(this)
    return this


  respondToQuery: (tr) ->
    tr.createMessage(@createResponsePayload())
      .sendToNodeTarget(@getNodeTarget())
    return this


  createResponsePayload: ->
    ValuePayload.create(null)
