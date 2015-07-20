'use strict'


assert = require 'assert'
WeakMap = require 'collections/weak-map'
FastMap = require 'collections/fast-map'
MultiMap = require 'collections/multi-map'
SortedArray = require 'collections/sorted-array'

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

  log: (args...) ->
    return this unless @loggingIsEnabled
    msg = args.map(inspect).join(', ')
    console.log msg if @loggingFilter(msg)
    return this


  reverseOrder: no

  constructor: ->
    @pointsToComms = new WeakMap()
    @nodesToPayloads = new WeakMap()
    @cachedMessagesForMerge = new MultiMap([], -> new FastMap())
    @commQueue = SortedArray([], Object.equals, => @compareComms(arguments...))
    @lastCommSeqNum = 0



  createInitialQuery: ->
    @Query.createInitial(this)

  createInitialMessage: (payload) ->
    @Message.createInitial(this, payload)

  createInitialConnectionMessage: (payload) ->
    @ConnectionMessage.createInitial(this, payload)



  # Common code for communications (queries and messages)
  tryQueryChannelNode: (comm, channelNode) ->
    if @communicationSucceedsExistingFor(comm, channelNode)
      channelNode.receiveQuery(@Query.createNextConnection(comm))
      false
    else
      true


  tryAddCommunicationFor: (comm, point) ->
    if @communicationSucceedsExistingFor(comm, point)
      @addCommunicationFor(comm, point)
      true
    else
      false


  addCommunicationFor: (comm, point) ->
    @pointsToComms.set(point, comm)
    return this


  compareArrays = (a, b) ->
    for i in [0...Math.max(a.length, b.length)]
      [elA, elB] = [a[i], b[i]]
      if elA > elB then return  1
      if elA < elB then return -1
    return 0


  communicationSucceedsExistingFor: (succComm, point) ->
    exisitingComm = @getCommunicationFor(point)
    if exisitingComm?
      @log point, succComm, exisitingComm,
        compareArrays(succComm.getPrecedence(), exisitingComm.getPrecedence())
    else
      @log point, succComm, exisitingComm
    return true if not exisitingComm?
    compareArrays(succComm.getPrecedence(), exisitingComm.getPrecedence()) == 1


  getCommunicationFor: (point) ->
    @pointsToComms.get(point)



  getCachedMessagesForMergeAt: (point) ->
    @cachedMessagesForMerge.get(point)



  addPayloadFor: (payload, node) ->
    @nodesToPayloads.set(node, payload)
    return this


  getPayloadFor: (node) ->
    @nodesToPayloads.get(node)



  enqueueCommunication: (comm) ->
    @commQueue.add([@lastCommSeqNum++, comm])
    return this


  compareComms: ([commASeqNum, commA], [commBSeqNum, commB]) ->
    r = if @reverseOrder then 1 else -1
    compareArrays(
      [commA.getQueueOrder()..., r * commASeqNum],
      [commB.getQueueOrder()..., r * commBSeqNum]
    )


  respond: ->
    while @commQueue.length
      [commSeqNum, comm] = @commQueue.shift()
      comm.respond()
    return this
