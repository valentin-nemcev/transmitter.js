'use strict'

Query = require './query'
Message = require './message'


module.exports = class Transmission

  constructor: ->
    @nodesToMessages = new Map()
    @nodesToQueries = new Map()


  createMessage: (payload) ->
    new Message(this, payload)


  createQuery: (createResponsePayload) ->
    new Query(this, createResponsePayload)


  addMessageFrom: (message, node) ->
    @nodesToMessages.set(node, message)
    return this


  getMessageFrom: (node) ->
    @nodesToMessages.get(node)


  addQueryTo: (query, node) ->
    @nodesToQueries.set(node, query)
    return this


  respondToQueries: ->
    for [node, query] in Array.from(@nodesToQueries.entries())
      continue if @getMessageFrom(node)?
      payload = query.createResponsePayload(node)
      message = @createMessage(payload)
      message.sendFromSourceNode(node)
    return this

