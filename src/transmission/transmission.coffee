'use strict'

Query = require './query'
Message = require './message'
ConnectionMessage = require './connection_message'

stable = require 'stable'


module.exports = class Transmission

  constructor: (opts = {}) ->
    @reverseOrder = opts.reverseOrder ? no
    @nodesToMessages = new Map()
    @nodesToQueries = new Map()
    @queryQueue = []


  createMessage: (payload) ->
    return new Message(this, payload)


  createConnectionMessage: (payload) ->
    return new ConnectionMessage(this, payload)


  createQuery: (direction) ->
    return new Query(this, direction)


  hasMessageForNode: (node) ->
    @nodesToMessages.has(node)


  addMessageForNode: (message, node) ->
    @nodesToMessages.set(node, message)
    return this


  getMessageFrom: (node) ->
    @nodesToMessages.get(node)


  enqueueQueryFromNode: (query, node, priority) ->
    @queryQueue.push {node, query, priority}
    return this


  addQueryToNode: (query, node) ->
    @nodesToQueries.set(node, query)
    return this


  hasQueryToNode: (node) ->
    @nodesToQueries.has(node)


  hasQueryOrMessageForNode: (node) ->
    @hasMessageForNode(node) or @hasQueryToNode(node)


  _sortQueryQueue: ->
    queue = @queryQueue.slice()
    queue.reverse() if @reverseOrder
    stable.inplace(queue, (a, b) -> a.priority < b.priority)
    return queue



  respondToQueries: ->
    queue = @_sortQueryQueue()
    for {node, query} in queue
      payload = node.createResponsePayload()
      message = @createMessage(payload)
      message.sendFromSourceNode(node)
    return this
