'use strict'

Query = require './query'
Message = require './message'


module.exports = class Transmission

  constructor: (opts = {}) ->
    @reverseOrder = opts.reverseOrder ? no
    @nodesToMessages = new Map()
    @nodesToQueries = new Map()


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


  addQueryTo: (query, node) ->
    @nodesToQueries.set(node, query)
    return this


  respondToQueries: ->
    queries = Array.from(@nodesToQueries.entries())
    queries.reverse() if @reverseOrder
    for [node, query] in queries
      continue if @getMessageFrom(node)?
      payload = query.createResponsePayload(node)
      message = @createMessage(payload)
      message.sendFromSourceNode(node)
    return this
