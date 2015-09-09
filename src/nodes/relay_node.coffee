'use strict'


NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'
noop = require '../payloads/noop'

module.exports = class RelayNode

  inspect: -> '[' + @constructor.name + ']'


  processPayload: (payload) ->
    @acceptPayload(payload)
    return @createResponsePayload(payload)


  getNodeSource: -> @nodeSource ?= new NodeSource(this)
  getNodeTarget: -> @nodeTarget ?= new NodeTarget(this)


  originate: (tr) ->
    tr.originateMessage(this, @createOriginPayload())
    return this


  init: (tr, value) ->
    @receivePayload(tr, @createUpdatePayload(value))


  receivePayload: (tr, payload) ->
    tr.originateMessage(this, payload)
    return this


  queryState: (tr) ->
    tr.createInitialQuery()
      .sendToNode(this)
    return this


  acceptPayload: -> this


  createResponsePayload: (payload) -> payload ? noop()


  createOriginPayload: ->


  createUpdatePayload: (value) ->
