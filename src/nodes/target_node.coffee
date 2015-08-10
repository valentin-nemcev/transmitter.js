'use strict'


NodeTarget = require '../connection/node_target'

noop = require '../payloads/noop'


module.exports = class TargetNode

  inspect: -> '[' + @constructor.name + ']'


  getNodeTarget: -> @nodeTarget ?= new NodeTarget(this)


  routeMessage: (tr, payload) ->
    @acceptPayload(payload)
    return this


  respondToQuery: (tr, prevPayload) ->
    tr.createQueryResponseMessage(@createResponsePayload(prevPayload))
      .sendToNodeTarget(@getNodeTarget())
    return this


  createResponsePayload: (payload) -> payload ? noop()
