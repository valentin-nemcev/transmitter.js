'use strict'


NodeSource = require '../connection/node_source'
BlindNodeTarget = require '../connection/blind_node_target'
VariablePayload = require '../payloads/variable'
noop = require '../payloads/noop'


module.exports = class SourceNode

  inspect: -> '[' + @constructor.name + ']'


  processPayload: (payload) ->
    return @createResponsePayload(payload)


  getNodeSource: -> @nodeSource ?= new NodeSource(this)
  getNodeTarget: -> @nodeTarget ?= new BlindNodeTarget(this)


  originate: (tr, value) ->
    tr.originateMessage(this, @createOriginPayload(value))
    return this


  createResponsePayload: (payload) -> payload ? noop()


  createOriginPayload: (value) ->
    VariablePayload.setConst(value)
