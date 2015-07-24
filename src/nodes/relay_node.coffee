'use strict'


NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'
noop = require '../payloads/noop'

module.exports = class RelayNode

  NodeSource.extend this
  NodeTarget.extend this

  inspect: -> '[' + @constructor.name + ']'


  routeMessage: (tr, payload) ->
    @acceptPayload(payload)
    tr.createNextMessage(@createResponsePayload(payload))
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  routeQuery: (tr) ->
    tr.createNextQuery()
      .sendFromNodeToNodeTarget(this, @getNodeTarget())
    return this


  respondToMessage: (tr) ->
    tr.createQueryForResponseMessage()
      .sendFromNodeToNodeTarget(this, @getNodeTarget())
    return this


  respondToQuery: (tr, prevPayload) ->
    tr.createQueryResponseMessage(@createResponsePayload(prevPayload))
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  originate: (tr) ->
    tr.createInitialMessage(@createOriginPayload())
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  init: (tr, value) ->
    tr.createInitialMessage(@createUpdatePayload(value))
      .sendToNodeTarget(@getNodeTarget())
    return this


  queryState: (tr) ->
    tr.createInitialQuery()
      .sendFromNodeToNodeTarget(this, @getNodeTarget())
    return this


  acceptPayload: -> this


  createResponsePayload: (payload) -> payload ? noop()


  createOriginPayload: ->


  createUpdatePayload: (value) ->
