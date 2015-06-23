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
    @pointsToComms = new Map()
    @queue = []



  createInitialQuery: ->
    @Query.createInitial(this)

  createInitialMessage: (payload) ->
    @Message.createInitial(this, payload)

  createInitialConnectionMessage: (payload) ->
    @ConnectionMessage.createInitial(this, payload)



  tryQueryLine: (comm, line) ->
    if not line.isConst() and @communicationSuccedsExistingFor(comm, line)
      line.receiveConnectionQuery(@Query.createNextConnection(comm))
      false
    else
      true


  tryAddCommunicationFor: (comm, point) ->
    if @communicationSuccedsExistingFor(comm, point)
      @addCommunicationFor(comm, point)
      true
    else
      false


  addCommunicationFor: (comm, point) ->
    @log 'addCommunicationFor', comm, point
    @pointsToComms.set(point, comm)
    return this


  compareArrays = (a, b) ->
    for i in [0...Math.max(a.length, b.length)]
      [elA, elB] = [a[i], b[i]]
      if elA > elB then return  1
      if elA < elB then return -1
    return 0


  communicationSuccedsExistingFor: (succComm, point) ->
    exisitingComm = @getCommunicationFor(point)
    return true if not exisitingComm?
    compareArrays(succComm.getPrecedence(), exisitingComm.getPrecedence()) == 1


  getCommunicationFor: (point) ->
    @pointsToComms.get(point)



  enqueue: (entry) ->
    @log 'enqueue', entry, entry.getQueueOrder()

    if @reverseOrder
      @queue.push entry
    else
      @queue.unshift entry
    stableSort.inplace @queue, (entryA, entryB) ->
      compareArrays(entryA.getQueueOrder(), entryB.getQueueOrder())
    return this


  respond: ->
    while @queue.length
      entry = @queue.shift()
      @log 'dequeue', entry, entry.getQueueOrder()
      entry.respond()
    return this
