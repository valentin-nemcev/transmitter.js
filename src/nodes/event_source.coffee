'use strict'


NodeSource = require '../connection/node_source'


module.exports = class EventSource

  NodeSource.extend this

  routeQuery: (query) ->
    query.completeRouting(this)
    return this


  respondToQuery: (sender) ->
    sender.createValueMessage(null).sendToNodeSource(@getNodeSource())
    return this


  originate: (value, sender) ->
    sender.createValueMessage(value).sendToNodeSource(@getNodeSource())
    return this
