'use strict'

Query = require './query'
Message = require './message'


module.exports = class Transmission

  constructor: ->
    @sendersToMessages = new Map()
    @queriesToNodes = new Map()


  createMessage: (payload) ->
    new Message(this, payload)


  createQuery: (createResponsePayload) ->
    new Query(this, createResponsePayload)


  addMessageFrom: (message, sender) ->
    @sendersToMessages.set(sender, message)
    return this


  getMessageFrom: (sender) ->
    @sendersToMessages.get(sender)


  addQueryTo: (query, node) ->
    @queriesToNodes.set(node, query)
    return this


  respondToQueries: ->
    for [node, query] in Array.from(@queriesToNodes.entries())
      payload = query.createResponsePayload(node)
      message = @createMessage(payload)
      message.sendFromSourceNode(node)
    return this

