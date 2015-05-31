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
    @pointsToMessages = new Map()
    @pointsToQueries = new Map()
    @queryQueue = []



  createInitialQuery: ->
    @createQuery({direction: directions.forward, precedence: 0})


  createInitialMessage: (payload) ->
    @createMessage(payload, precedence: 0)


  createInitialConnectionMessage: (payload) ->
    @createConnectionMessage(payload)


  createQuery: (opts) ->
    new Query(this, opts)


  createMessage: (payload, opts) ->
    new Message(this, payload, opts)


  createConnectionMessage: (payload, opts) ->
    new ConnectionMessage(this, payload, opts)



  addMessageFor: (message, point) ->
    @_log 'addMessageFor', arguments...
    @pointsToMessages.set(point, message)
    return this


  hasMessageFor: (point) ->
    @pointsToMessages.has(point)


  getMessageFor: (point) ->
    @pointsToMessages.get(point)



  addQueryFor: (query, point) ->
    @_log 'addQueryFor', arguments...
    @pointsToQueries.set(point, query)
    return this


  getQueryFor: (point) ->
    @pointsToQueries.get(point)



  enqueueQueryFor: (query, point, order) ->
    @_log 'enqueueQueryFor', arguments...

    entry = {point, query, order}
    if @reverseOrder
      @queryQueue.push entry
    else
      @queryQueue.unshift entry
    stableSort.inplace @queryQueue, (afterEntry, beforeEntry) ->
      afterEntry.order > beforeEntry.order
    return this


  respondToQueries: ->
    while @queryQueue.length
      {point, query, order} = @queryQueue.shift()
      @_log 'popQueue', point, order
      point.respondToQuery(query)
    return this
