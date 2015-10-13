'use strict'


assert = require 'assert'
WeakMap = require 'collections/weak-map'
SortedArray = require 'collections/sorted-array'

{inspect} = require 'util'

Pass = require './pass'


module.exports = class Transmission

  Query             : require './query'
  Message           : require './message'
  ConnectionMessage : require './connection_message'
  JointMessage      : require './joint_message'

  @start = (doWithTransmission) ->
    # assert(not @instance, "Transmissions can't be nested")
    @instance = new Transmission()
    do
    # try
      console.profile() if @profilingIsEnabled
      doWithTransmission(@instance)
      @instance.respond()
      console.profileEnd() if @profilingIsEnabled
    # finally
      @instance = null
    return this


  @profilingIsEnabled = no

  loggingIsEnabled: no

  loggingFilter: -> true

  log: ->
    return this unless @loggingIsEnabled
    msg = (inspect arg for arg in arguments).join(', ')
    console.log msg if @loggingFilter(msg)
    return this


  logQueue: ->
    return this unless @loggingIsEnabled
    nextComm = @commQueue[0][1]
    return this unless @loggingFilter(inspect nextComm.sourceNode)
    message = []
    filteredCounter = 0
    for [commSeqNum, comm] in @commQueue
      msg = [comm, comm.sourceNode]
        .map(inspect).join(' for ').replace(/\s+/gi, ' ')
      if @loggingFilter(msg)
        filteredCounter = 0
        message.push msg
      else
        if filteredCounter
          message.pop()
        filteredCounter++
        message.push "(#{filteredCounter} skipped)"
    console.log message.join('\n  ')
    return this


  reverseOrder: no


  inspect: -> '[Transmission]'


  constructor: ->
    @comms = for priority in [0..Pass.maxPriority]
      {map: new WeakMap(), queue: []}



  createInitialConnectionMessage: ->
    @ConnectionMessage.createInitial(this)


  originateQuery: (node) ->
    @JointMessage.getOrCreate(
      {transmission: this, pass: Pass.createQueryDefault()},
      {node: node}
    ).originateQuery()


  originateMessage: (node, payload) ->
    @JointMessage.getOrCreate(
      {transmission: this, pass: Pass.createMessageDefault()},
      {node: node}
    ).originateMessage(payload)



  addCommunicationForAndEnqueue: (comm, point) ->
    @addCommunicationFor(comm, point, yes)


  addCommunicationFor: (comm, point, enqueue = no) ->
    {map, queue} = @comms[comm.pass.priority]
    map.set(point, comm)
    if enqueue
      if @reverseOrder
        queue.unshift(comm)
      else
        queue.push(comm)
    return this


  getCommunicationFor: (pass, point) ->
    return null if pass is null
    @comms[pass.priority].map.get(point)



  respond: ->
    for {queue} in @comms
      loop
        didRespond = no
        # Use while loop to handle comms pushed to queue in single iteration
        i = 0
        while i < queue.length
          comm = queue[i++]
          if comm.readyToRespond()
            didRespond = yes
            comm.respond()
        break unless didRespond
    return this
