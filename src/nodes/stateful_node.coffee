'use strict'


NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'

ValuePayload = require '../payloads/value'
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


  originate: (tr) ->
    tr.createMessage(@createOriginPayload())
      .sendToNodeSource(@getNodeSource())
    return this


  updateState: (value, tr) ->
    tr.createMessage(@createUpdatePayload(value))
      .sendToNodeTarget(@getNodeTarget())
    return this


  queryState: (tr) ->
    tr.createQuery(directions.forward).sendToNodeTarget(@getNodeTarget())
    return this


  createResponsePayload: ->
    ValuePayload.create(this)


  createRelayPayload: ->
    ValuePayload.create(this)


  createOriginPayload: ->
    ValuePayload.create(this)


  createUpdatePayload: (value) ->
    ValuePayload.createFromValue(value)
