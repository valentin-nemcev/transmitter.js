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
    @queriedChannelNodes.add(channelNode)
    @transmission.tryQueryChannelNode(this, channelNode)


  addPassedChannelNode: (channelNode) ->
    @queriedChannelNodes.remove(channelNode)
    @tryEnqueue()
    return this


  sendToLine: (line) ->
    @log line
    @passedLines.add(line)
    line.receiveQuery(this)
    return this


  getPassedLines: -> @passedLines


  _sendToNodePoint: (point, isTarget) ->
    @log point
    existing = @transmission.getCommunicationFor('query', @pass, point)
    if existing?
      existing.join(this)
      @delivered = yes
    else
      @transmission.addCommunicationFor(this, point)
      point.receiveQuery(this)
      if isTarget
        @sentToNodeTarget = yes
        @tryEnqueue()
    return this


  sendToNodeSource: (nodeSource) ->
    @_sendToNodePoint(nodeSource)


  sendToChannelNode: (node) ->
    @log node
    node.receiveQuery(this)
    return this


  sendToNode: (node) ->
    @log node
    @transmission.SelectedMessage.getOrCreate(this, node.getNodeTarget())
      .joinQuery(this)
    return this


  sendToNodeTarget: (@nodeTarget) ->
    @_sendToNodePoint(@nodeTarget, yes)


  enqueueForSourceNode: (@sourceNode) ->
    @transmission.enqueueCommunication(this)
    return this


  getSourceNode: -> @sourceNode ? @nodeTarget.node


  tryEnqueue: ->
    if @sentToNodeTarget \
      and @queriedChannelNodes.length is 0 \
      and @passedLines.length is 0
        @log 'enqueue', @getSourceNode()
        @transmission.enqueueCommunication(this)
    return this


  wasDelivered: ->
    @delivered or @passedLines.length > 0


  getQueuePrecedence: ->
    @queuePrecedence ?=
      Precedence.createQueue(@pass, @communicationTypePriority)



  readyToRespond: -> @areAllChannelNodesUpdated()


  areAllChannelNodesUpdated: ->
    for node in @nodeTarget?.getChannelNodesFor(this) ? []
      return false unless @transmission.channelNodeUpdated(this, node)
    return true


  respond: ->
    unless @wasDelivered()
      @log 'respond', @getSourceNode()
      @getSourceNode().respondToQuery(this,
        @transmission.getPayloadFor(@getSourceNode()))
    return this
