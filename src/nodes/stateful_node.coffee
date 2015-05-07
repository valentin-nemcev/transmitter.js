'use strict'


NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'

{StatePayload} = require '../transmission/payloads'
directions = require '../directions'

module.exports = class StatefulNode

  NodeSource.extend this
  NodeTarget.extend this


  routeMessage: (payload, tr) ->
    payload.deliver(this)
    tr.createMessage(StatePayload.create(this))
      .sendToNodeSource(@getNodeSource())
    return this


  routeQuery: (query) ->
    query.sendToNodeTarget(@getNodeTarget())
    return this


  respondToQuery: (tr) ->
    tr.createMessage(StatePayload.create(this))
      .sendToNodeSource(@getNodeSource())
    return this


  updateState: (value, tr) ->
    tr.createMessage(StatePayload.createFromValue(value))
      .sendToNodeTarget(@getNodeTarget())
    return this


  queryState: (tr) ->
    tr.createQuery(directions.forward).sendToNodeTarget(@getNodeTarget())
    return this
