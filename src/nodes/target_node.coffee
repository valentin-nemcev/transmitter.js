'use strict'


NodeTarget = require '../connection/node_target'

ValuePayload = require '../payloads/value'


module.exports = class TargetNode

  NodeTarget.extend this

  routeMessage: (payload, tr) ->
    payload.deliverToTargetNode(this)
    return this


  respondToQuery: (tr) ->
    tr.createMessage(@createResponsePayload())
      .sendToNodeTarget(@getNodeTarget())
    return this


  createResponsePayload: ->
    ValuePayload.create(null)
