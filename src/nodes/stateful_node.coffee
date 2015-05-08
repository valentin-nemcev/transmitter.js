'use strict'


NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'

{StatePayload} = require '../transmission/payloads'
directions = require '../directions'

module.exports = class StatefulNode

  NodeSource.extend this
  NodeTarget.extend this


  routeMessage: (payload, tr) ->
    payload.deliver(this)
    tr.createMessage(@createResponsePayload())
      .sendToNodeSource(@getNodeSource())
    return this


  routeQuery: (query) ->
    query.sendToNodeTarget(@getNodeTarget())
    return this


  respondToQuery: (tr) ->
    tr.createMessage(@createResponsePayload())
      .sendToNodeSource(@getNodeSource())
    return this


  updateState: (value, tr) ->
    tr.createMessage(@createOriginPayload(value))
      .sendToNodeTarget(@getNodeTarget())
    return this


  queryState: (tr) ->
    tr.createQuery(directions.forward).sendToNodeTarget(@getNodeTarget())
    return this


  createResponsePayload: ->
    StatePayload.create(this)


  createRelayPayload: ->
    StatePayload.create(this)


  createOriginPayload: (value) ->
    StatePayload.createFromValue(value)
