'use strict'


stableSort = require 'stable'
{inspect} = require 'util'

Query = require './query'
Message = require './message'
ConnectionMessage = require './connection_message'


module.exports = class Transmission

  _log: (name, args...) ->
    console.log name, args.map(inspect).join(', ') if @loggingIsEnabled
    return this


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
    @_log 'addMessageForNode', arguments...
    @nodesToMessages.set(node, message)
    return this


  getMessageFrom: (node) ->
    @nodesToMessages.get(node)


  enqueueQueryFromNode: (query, node, priority) ->
    @_log 'enqueueQueryFromNode', arguments...

    entry = {node, query, priority}
    if @reverseOrder
      @queryQueue.push entry
    else
      @queryQueue.unshift entry
    stableSort.inplace(@queryQueue, (a, b) -> a.priority > b.priority)
    return this


  addQueryToNode: (query, node) ->
    @_log 'addQueryToNode', arguments...
    @nodesToQueries.set(node, query)
    return this


  hasQueryToNode: (node) ->
    @nodesToQueries.has(node)


  getQueryFromNode: (node) ->
    @nodesToQueries.get(node)


  hasQueryOrMessageForNode: (node) ->
    @hasMessageForNode(node) or @hasQueryToNode(node)


  _sortQueryQueue: ->
    queue = @queryQueue.slice()
    queue.reverse() if @reverseOrder
    return queue


  respondToQueries: ->
    queue = @_sortQueryQueue()
    while @queryQueue.length
      {node, query} = @queryQueue.pop()
      payload = node.createResponsePayload()
      message = @createMessage(payload)
      message.sendFromSourceNode(node)
    return this
