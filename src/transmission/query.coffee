'use strict'


{inspect} = require 'util'

FastSet = require 'collections/fast-set'
Pass = require './pass'
Precedence = require './precedence'


module.exports = class Query

  inspect: ->
    [
      'Q',
      inspect @pass
      @wasDelivered() and 'D' or ''
    ].filter( (s) -> s.length).join(' ')


  log: ->
    args = [this]
    args.push arg for arg in arguments
    @transmission.log args...
    return this


  @getNullQuery = -> @nullQuery ?= new NullQuery()

  getNullQuery: -> Query.getNullQuery()


  @createInitial = (transmission) ->
    new this(transmission,
      pass: Pass.createQueryDefault(),
    )


  @createNext = (prevQuery) ->
    new this(prevQuery.transmission, {
      pass: prevQuery.pass
    })


  @createNextConnection = (prevMessageOrQuery) ->
    new this(prevMessageOrQuery.transmission, {
      pass: prevMessageOrQuery.pass
    })


  @createForMerge = (mergedMessage) ->
    new this(mergedMessage.transmission, {
      pass: mergedMessage.pass
    })


  constructor: (@transmission, opts = {}) ->
    {@pass} = opts
    @passedLines = new FastSet()
    @queriedChannelNodes = new FastSet()


  createNextQuery: ->
    Query.createNext(this)


  createQueryResponseMessage: (payload) ->
    @transmission.Message.createQueryResponse(this, payload)



  directionMatches: (direction) -> @pass.directionMatches(direction)


  type: 'query'

  communicationTypePriority: 0


  # TODO
  join: (comm) ->
    return this


  getUpdatePrecedence: ->
    @updatePrecedence ?=
      Precedence.createUpdate(@pass)


  tryQueryChannelNode: (channelNode) ->
    @transmission.tryQueryChannelNode(this, channelNode)


  sendToLine: (line) ->
    @log line
    @passedLines.add(line)
    line.receiveQuery(this)
    return this


  getPassedLines: -> @passedLines


  sendToNodeSource: (nodeSource) ->
    @log nodeSource
    existing = @transmission.getCommunicationFor('query', @pass, nodeSource)
    if existing?
      existing.join(this)
    else
      @transmission.addCommunicationFor(this, nodeSource)
      nodeSource.receiveQuery(this)
    return this


  sendToChannelNode: (node) ->
    @log node
    node.receiveQuery(this)
    return this


  sendToNode: (node) ->
    @log node
    @transmission.SelectedMessage.getOrCreate(this, {node})
      .joinQuery(this)
    return this


  enqueueForSourceNode: (@sourceNode) ->
    @transmission.enqueueCommunication(this)
    return this


  getSourceNode: -> @sourceNode


  tryEnqueue: (@sourceNode) ->
    unless @wasDelivered()
      @log 'enqueue', @getSourceNode()
      @transmission.enqueueCommunication(this)
    return this


  wasDelivered: ->
    @passedLines.length > 0


  getQueuePrecedence: ->
    @queuePrecedence ?=
      Precedence.createQueue(@pass, @communicationTypePriority)



  readyToRespond: -> @areAllChannelNodesUpdated()


  areAllChannelNodesUpdated: ->
    # TODO
    for node in @sourceNode?.getNodeTarget?()?.getChannelNodesFor(this) ? []
      return false unless @transmission.channelNodeUpdated(this, node)
    return true


  respond: ->
    unless @wasDelivered()
      @log 'respond', @getSourceNode()
      @getSourceNode().respondToQuery(this,
        @transmission.getPayloadFor(@getSourceNode()))
    return this
