'use strict'


assert = require 'assert'

stableSort = require 'stable'
directions = require '../directions'
{inspect} = require 'util'

Query = require './query'
Message = require './message'
ConnectionMessage = require './connection_message'


module.exports = class Transmission

  @start = (doWithTransmission) ->
    assert(not @instance, "Transmissions can't be nested")
    @instance = new Transmission()
    try
      doWithTransmission(@instance)
      @instance.respond()
    finally
      @instance = null
    return this


  loggingIsEnabled: no

  loggingFilter: -> true

  log: (name, args...) ->
    return this unless @loggingIsEnabled
    msg = args.map(inspect).join(', ')
    console.log name, msg if @loggingFilter(msg)
    return this


  reverseOrder: no

  constructor: ->
    @pointsToMessages = new Map()
    @pointsToQueries = new Map()
    @queue = []



  createInitialQuery: ->
    @createQuery({direction: directions.forward, precedence: 1, nesting: 0})


  createInitialMessage: (payload) ->
    @createMessage(payload,
      direction: directions.backward, precedence: 0, nesting: 0)


  createInitialConnectionMessage: (payload) ->
    @createConnectionMessage(payload)


  createQuery: (opts) ->
    new Query(this, opts)


  createMessage: (payload, opts) ->
    new Message(this, payload, opts)


  createConnectionMessage: (payload, opts) ->
    new ConnectionMessage(this, payload, opts)



  addMessageFor: (message, point) ->
    @log 'addMessageFor', arguments...
    @pointsToMessages.set(point, message)
    return this


  hasMessageFor: (point) ->
    @pointsToMessages.has(point)


  getMessageFor: (point) ->
    @pointsToMessages.get(point)



  addQueryFor: (query, point) ->
    @log 'addQueryFor', arguments...
    @pointsToQueries.set(point, query)
    return this


  getQueryFor: (point) ->
    @pointsToQueries.get(point)



  enqueue: (entry) ->
    @log 'enqueue', entry, entry.node

    if @reverseOrder
      @queue.push entry
    else
      @queue.unshift entry
    stableSort.inplace @queue, (entryBefore, entryAfter) ->
      entryBefore.getQueueOrder() > entryAfter.getQueueOrder()
    return this


  respond: ->
    while @queue.length
      entry = @queue.shift()
      @log 'dequeue', entry, entry.node
      entry.respond()
    return this
