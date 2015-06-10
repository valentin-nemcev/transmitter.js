'use strict'


NodeSource = require '../connection/node_source'

ValuePayload = require '../payloads/value'


module.exports = class SourceNode

  NodeSource.extend this

  inspect: -> '[' + @constructor.name + ']'


  routeQuery: (tr) ->
    tr.createNextQuery().enqueueForSourceNode(this)
    return this


  respondToQuery: (tr) ->
    tr.createNextMessage(@createResponsePayload())
      .sendToNodeSource(@getNodeSource())
    return this


  originate: (tr, value) ->
    tr.createInitialMessage(@createOriginPayload(value))
      .sendToNodeSource(@getNodeSource())
    return this


  createResponsePayload: ->
    ValuePayload.createFromValue(null)


  createOriginPayload: (value) ->
    ValuePayload.createFromValue(value)
