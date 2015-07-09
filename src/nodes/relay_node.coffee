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
      .sendFromNodeToNodeTarget(this, @getNodeTarget())
    return this


  respondToMessage: (tr, payload) ->
    tr.createMessageResponseMessage(@createResponsePayload())
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  respondToQuery: (tr) ->
    tr.createQueryResponseMessage(@createResponsePayload())
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
      .sendFromNodeToNodeTarget(this, @getNodeTarget())
    return this


  createResponsePayload: ->


  createRelayPayload: ->


  createOriginPayload: ->


  createUpdatePayload: (value) ->
