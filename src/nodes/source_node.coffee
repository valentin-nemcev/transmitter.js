'use strict'


NodeSource = require '../connection/node_source'

ValuePayload = require '../payloads/value'


module.exports = class SourceNode

  NodeSource.extend this

  inspect: -> '[' + @constructor.name + ']'


  routeQuery: (query) ->
    query.completeRouting(this)
    return this


  respondToQuery: (tr) ->
    tr.createMessage(@createResponsePayload())
      .sendToNodeSource(@getNodeSource())
    return this


  originate: (tr, value) ->
    tr.createMessage(@createOriginPayload(value))
      .sendToNodeSource(@getNodeSource())
    return this


  createResponsePayload: ->
    ValuePayload.createFromValue(null)


  createOriginPayload: (value) ->
    ValuePayload.createFromValue(value)
