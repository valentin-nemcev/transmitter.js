'use strict'


BlindNodeSource = require '../connection/blind_node_source'
NodeTarget = require '../connection/node_target'

noop = require '../payloads/noop'


module.exports = class TargetNode

  inspect: -> '[' + @constructor.name + ']'


  getNodeSource: -> @nodeSource ?= new BlindNodeSource(this)
  getNodeTarget: -> @nodeTarget ?= new NodeTarget(this)


  processPayload: (payload) ->
    @acceptPayload(payload)
    return @createResponsePayload(payload)


  createResponsePayload: (payload) -> payload ? noop()
