'use strict'


NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'

module.exports = class RelayNode

  NodeSource.extend this
  NodeTarget.extend this

  inspect: -> '[' + @constructor.name + ']'


  routeMessage: (tr, payload) ->
    @acceptPayload(payload)
    tr.createNextMessage(@createResponsePayload())
      .sendToNodeSource(@getNodeSource())
    return this


  routeQuery: (tr) ->
    tr.createNextQuery().sendToNodeTarget(@getNodeTarget()).enqueue(this)
    return this


  respondToQuery: (tr) ->
    tr.createNextMessage(@createResponsePayload())
      .sendToNodeSource(@getNodeSource())
    return this


  originate: (tr) ->
    tr.createInitialMessage(@createOriginPayload())
      .sendToNodeSource(@getNodeSource())
    return this


  updateState: (tr, value) ->
    tr.createInitialMessage(@createUpdatePayload(value))
      .sendToNodeTarget(@getNodeTarget())
    return this


  queryState: (tr) ->
    tr.createInitialQuery().sendToNodeTarget(@getNodeTarget())
    return this


  createResponsePayload: ->


  createRelayPayload: ->


  createOriginPayload: ->


  createUpdatePayload: (value) ->
