'use strict'


NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'

directions = require '../directions'

module.exports = class RelayNode

  NodeSource.extend this
  NodeTarget.extend this

  inspect: -> '[' + @constructor.name + ']'


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


  createRelayPayload: ->


  createOriginPayload: ->


  createUpdatePayload: (value) ->
