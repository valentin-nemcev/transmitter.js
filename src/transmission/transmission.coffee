'use strict'


assert = require 'assert'
WeakMap = require 'collections/weak-map'
SortedArray = require 'collections/sorted-array'

{inspect} = require 'util'


module.exports = class Transmission

  Query             : require './query'
  Message           : require './message'
  ConnectionMessage : require './connection_message'
  SelectedMessage   : require './selected_message'

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

  constructor: ->
    @pointsToQueries = new WeakMap()
    @pointsToMessages = new WeakMap()

    @nodesToPayloads = new WeakMap()
    @cachedMessages = new WeakMap()
    # @commQueue = SortedArray([], Object.equals, => @compareComms(arguments...))
    @commQueue = new Array()
    @lastCommSeqNum = 0



  createInitialQuery: ->
    @Query.createInitial(this)

  createInitialMessage: (payload) ->
    @Message.createInitial(this, payload)

  createInitialConnectionMessage: ->
    @ConnectionMessage.createInitial(this)



  # Common code for communications (queries and messages)
  tryQueryChannelNode: (comm, channelNode) ->
    if not @channelNodeUpdated(comm, channelNode)
      @Query.createNextConnection(comm).sendToChannelNode(channelNode)
      false
    else
      true


  channelNodeUpdated: (comm, channelNode) ->
    channelNode is null or @getCommunicationFor('message', comm.pass, channelNode)


  addCommunicationFor: (comm, point) ->
    comms = @_getCommsByType(comm.type)
    byPass = comms.get(point) ? []
    byPass[comm.pass.priority] = comm
    comms.set(point, byPass)
    return this


  getCommunicationFor: (type, pass, point) ->
    return null if pass is null
    (@_getCommsByType(type).get(point) ? [])[pass.priority]


  _getCommsByType: (type) ->
    switch type
      when 'query'   then @pointsToQueries
      when 'message' then @pointsToMessages
      else throw new Error "Unknown communication type: #{type}"



  getCachedMessage: (point) ->
    @cachedMessages.get(point)


  setCachedMessage: (point, message) ->
    @cachedMessages.set(point, message)
    return this


  addPayloadFor: (payload, node) ->
    @nodesToPayloads.set(node, payload)
    return this


  getPayloadFor: (node) ->
    @nodesToPayloads.get(node)



  enqueueCommunication: (comm) ->
    @commQueue.add([@lastCommSeqNum++, comm])
    return this


  compareComms: ([commASeqNum, commA], [commBSeqNum, commB]) =>
    r = if @reverseOrder then 1 else -1
    commA.getQueuePrecedence().compare(commB.getQueuePrecedence()) \
      or r * (commASeqNum - commBSeqNum)


  respond: ->
    while @commQueue.length
      @commQueue.sort(@compareComms)
      # @logQueue()
      for i in [0...@commQueue.length]
        [commSeqNum, comm] = @commQueue[i]
        if comm.readyToRespond()
          @commQueue.splice(i, 1)
          comm.respond()
          break
    return this
