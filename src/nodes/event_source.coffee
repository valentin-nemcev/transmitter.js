'use strict'


NodeSource = require '../connection/node_source'

{ValuePayload} = require '../transmission/payloads'


module.exports = class EventSource

  NodeSource.extend this

  routeQuery: (query) ->
    query.completeRouting(this)
    return this


  respondToQuery: (tr) ->
    tr.createMessage(ValuePayload.create(null))
      .sendToNodeSource(@getNodeSource())
    return this


  originate: (value, tr) ->
    tr.createMessage(ValuePayload.create(value))
      .sendToNodeSource(@getNodeSource())
    return this
