'use strict'


{inspect} = require 'util'

FastSet = require 'collections/fast-set'
Pass = require './pass'
Precedence = require './precedence'


class NullQuery
  sendFromNodeToNodeTarget: -> this
  enqueueForSourceNode: -> this


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


  @createForSelect = (selectedMessage) ->
    new this(selectedMessage.transmission, {
      pass: selectedMessage.pass
    })


  @createForResponseMessage = (queuedMessage) ->
    pass = queuedMessage.pass.getForResponse()
    if pass?
      new this(queuedMessage.transmission, {
        pass
      })
    else
      @getNullQuery()



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
    line.receiveQuery(this)
    return this


  getPassedLines: -> @passedLines


  addPassedLine: (line) ->
    @passedLines.add(line)
    return this


  _sendToNodePoint: (point, node) ->
    @log point
    existing = @transmission.getCommunicationFor('query', @pass, point)
    existing ?= @transmission.getCommunicationFor('message', @pass, point)
    existing ?= @transmission.getCommunicationFor('message', @pass.getNext(), point)
    if existing?
      existing.join(this)
      @delivered = yes
    else
      @transmission.addCommunicationFor(this, point)
      point.receiveQuery(this)
      if node
        @sentToNodeTarget = yes
        @tryEnqueue()
    return this


  resendFromNodePoint: (point, channelNode, connectionMessage) ->
    point.resendQuery(this, channelNode)
    return this


  sendToNodeSource: (nodeSource) ->
    @_sendToNodePoint(nodeSource)


  sendToChannelNode: (node) ->
    @log node
    node.receiveQuery(this)
    return this


  sendToNode: (node) ->
    @log node
    node.routeQuery(this)
    return this


  sendFromNodeToNodeTarget: (@sourceNode, @nodeTarget) ->
    @_sendToNodePoint(@nodeTarget, @sourceNode)


  enqueueForSourceNode: (@sourceNode) ->
    @transmission.enqueueCommunication(this)
    return this


  tryEnqueue: ->
    if @sentToNodeTarget \
      and @queriedChannelNodes.length is 0 \
      and @passedLines.length is 0
        @log 'enqueue', @sourceNode
        @transmission.enqueueCommunication(this)
    return this


  wasDelivered: ->
    @delivered or @passedLines.length > 0


  getQueuePrecedence: ->
    @queuePrecedence ?=
      Precedence.createQueue(@pass, @communicationTypePriority)


  _channelNodesUpdated: ->


  readyToRespond: ->
    for node in @nodeTarget?.getChannelNodesFor(this) ? []
      return false unless @transmission.channelNodeUpdated(this, node)
    return true


  respond: ->
    unless @wasDelivered()
      @log 'respond', @sourceNode
      @sourceNode.respondToQuery(this,
        @transmission.getPayloadFor(@sourceNode))
    return this
