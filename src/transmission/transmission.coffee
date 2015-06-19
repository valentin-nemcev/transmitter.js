'use strict'


assert = require 'assert'

stableSort = require 'stable'
{inspect} = require 'util'



module.exports = class Transmission

  Query             : require './query'
  Message           : require './message'
  ConnectionMessage : require './connection_message'

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
    @Query.createInitial(this)

  createInitialMessage: (payload) ->
    @Message.createInitial(this, payload)

  createInitialConnectionMessage: (payload) ->
    @ConnectionMessage.createInitial(this, payload)



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
