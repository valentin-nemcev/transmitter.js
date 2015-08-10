'use strict'


NodeSource = require '../connection/node_source'
BlindNodeTarget = require '../connection/blind_node_target'
VariablePayload = require '../payloads/variable'
noop = require '../payloads/noop'


module.exports = class SourceNode

  inspect: -> '[' + @constructor.name + ']'


  getNodeSource: -> @nodeSource ?= new NodeSource(this)
  getNodeTarget: -> @nodeTarget ?= new BlindNodeTarget(this)


  routeQuery: (tr) ->
    tr.createNextQuery()
      .sendFromNodeToNodeTarget(this, @getNodeTarget())
    return this


  respondToMessage: (tr) ->
    tr.createQueryForResponseMessage()
      .sendFromNodeToNodeTarget(this, @getNodeTarget())
    return this


  respondToQuery: (tr, prevPayload) ->
    tr.createQueryResponseMessage(prevPayload ? @createResponsePayload())
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  originate: (tr, value) ->
    tr.createInitialMessage(@createOriginPayload(value))
      .sendFromNodeToNodeSource(this, @getNodeSource())
    return this


  createResponsePayload: ->
    noop()


  createOriginPayload: (value) ->
    VariablePayload.setConst(value)
