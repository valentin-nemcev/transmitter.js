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
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  routeQuery: (tr) ->
    tr.createNextQuery()
      .enqueueForSourceNode(this).sendToNodeTarget(@getNodeTarget())
    return this


  respondToMessage: (tr) ->
    tr.createResponseMessage(@createResponsePayload())
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  respondToQuery: (tr) ->
    tr.createNextMessage(@createResponsePayload())
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  originate: (tr) ->
    tr.createInitialMessage(@createOriginPayload())
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  updateState: (tr, value) ->
    tr.createInitialMessage(@createUpdatePayload(value))
      .sendToNodeTarget(@getNodeTarget())
    return this


  queryState: (tr) ->
    tr.createInitialQuery()
      .enqueueForSourceNode(this).sendToNodeTarget(@getNodeTarget())
    return this


  createResponsePayload: ->


  createRelayPayload: ->


  createOriginPayload: ->


  createUpdatePayload: (value) ->
