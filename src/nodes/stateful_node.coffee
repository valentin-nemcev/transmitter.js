'use strict'


NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'

module.exports = class StatefulNode

  NodeSource.extend this
  NodeTarget.extend this


  routeMessage: (payload, sender) ->
    payload.deliver(this)
    sender.createStateMessage(this).sendToNodeSource(@getNodeSource())
    return this


  routeQuery: (query) ->
    query.sendToNodeTarget(@getNodeTarget())
    return this


  respondToQuery: (sender) ->
    sender.createStateMessage(this).sendToNodeSource(@getNodeSource())
    return this


  updateState: (value, sender) ->
    sender.createStateValueMessage(value).sendToNodeTarget(@getNodeTarget())
    return this
