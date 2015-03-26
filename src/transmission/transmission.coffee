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


  createQuery: (createResponsePayload) ->
    new Query(this, createResponsePayload)


  hasMessageForNode: (node) ->
    @nodesToMessages.has(node)


  addMessageForNode: (message, node) ->
    @nodesToMessages.set(node, message)
    return this


  getMessageFrom: (node) ->
    @nodesToMessages.get(node)


  enqueueQueryForResponseFromNode: (query, node) ->
    @queryQueue.push [node, query]
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
    for [node, query] in queries
      payload = query.createResponsePayload(node)
      message = @createMessage(payload)
      message.sendFromSourceNode(node)
    return this
