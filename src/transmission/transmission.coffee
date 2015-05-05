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
    @pointsToMessages = new Map()
    @pointsToQueries = new Map()
    @queryQueue = []


  getSender: -> @sender ?= new Sender(this)



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



  enqueueQueryFor: (query, point, priority) ->
    @_log 'enqueueQueryFor', arguments...

    entry = {point, query, priority}
    if @reverseOrder
      @queryQueue.push entry
    else
      @queryQueue.unshift entry
    stableSort.inplace(@queryQueue, (a, b) -> a.priority > b.priority)
    return this


  respondToQueries: ->
    while @queryQueue.length
      {point, query} = @queryQueue.pop()
      point.respondToQuery(@getSender())
    return this
