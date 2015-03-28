'use strict'

Query = require './query'
Message = require './message'


module.exports = class Transmission

  constructor: (opts = {}) ->
    @reverseOrder = opts.reverseOrder ? no
    @nodesToMessages = new Map()
    @nodesToQueries = new Map()
    @queryQueue = []


  createMessage: (payload) ->
    new Message(this, payload)


  createQuery: (createResponsePayload, direction) ->
    new Query(this, createResponsePayload, direction)


  hasMessageForNode: (node) ->
    @nodesToMessages.has(node)


  addMessageForNode: (message, node) ->
    @nodesToMessages.set(node, message)
    return this


  getMessageFrom: (node) ->
    @nodesToMessages.get(node)


  enqueueQueryForResponseFromNode: (query, node) ->
    @queryQueue.push {source: node, query}
    return this


  enqueueQueryForResponseToNode: (query, node) ->
    @queryQueue.push {target: node, query}
    return this


  addQueryToNode: (query, node) ->
    @nodesToQueries.set(node, query)
    return this


  hasQueryToNode: (node) ->
    @nodesToQueries.has(node)


  hasQueryOrMessageForNode: (node) ->
    @hasMessageForNode(node) or @hasQueryToNode(node)


  respondToQueries: ->
    queries = @queryQueue.slice()
    queries.reverse() if @reverseOrder
    for {source, target, query} in queries
      payload = query.createResponsePayload(source or target)
      message = @createMessage(payload)
      if source
        message.sendFromSourceNode(source)
      if target
        message.sendToTargetNode(target)
    return this
