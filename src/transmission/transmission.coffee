'use strict'

Query = require './query'
Message = require './message'

stable = require 'stable'


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


  enqueueQueryFromNode: (query, node, priority) ->
    @queryQueue.push {source: node, query, priority}
    return this


  enqueueQueryToNode: (query, node, priority) ->
    @queryQueue.push {target: node, query, priority}
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
    for {source, target, query} in queue
      payload = query.createResponsePayload(source or target)
      message = @createMessage(payload)
      if source
        message.sendFromSourceNode(source)
      if target
        message.sendToTargetNode(target)
    return this
