'use strict'


assert = require 'assert'

stableSort = require 'stable'
{inspect} = require 'util'

Sender = require './sender'


module.exports = class Transmission

  @start = (doWithTransmission) ->
    assert(not @instance, "Transmissions can't be nested")
    @instance = new Transmission()
    try
      doWithTransmission(@instance.getSender())
      @instance.respondToQueries()
    finally
      @instance = null
    return this


  loggingIsEnabled: no

  _log: (name, args...) ->
    console.log name, args.map(inspect).join(', ') if @loggingIsEnabled
    return this


  reverseOrder: no

  constructor: ->
    @nodesToMessages = new Map()
    @nodesToQueries = new Map()
    @queryQueue = []


  getSender: -> @sender ?= new Sender(this)


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


  respondToQueries: ->
    while @queryQueue.length
      {node, query} = @queryQueue.pop()
      node.getResponseMessage(@getSender()).sendFromSourceNode(node)
    return this
