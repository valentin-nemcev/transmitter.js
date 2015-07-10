'use strict'


NodeSource = require '../connection/node_source'
VariablePayload = require '../payloads/variable'
noop = require '../payloads/noop'


module.exports = class SourceNode

  NodeSource.extend this

  inspect: -> '[' + @constructor.name + ']'


  routeQuery: (tr) ->
    tr.createNextQuery().enqueueForSourceNode(this)
    return this


  respondToMessage: (tr) ->
    tr.createQueryForResponseMessage()
      .enqueueForSourceNode(this)
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
