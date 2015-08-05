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
      inspect @nesting
      inspect @pass
      @wasDelivered() and 'D' or ''
    ].filter( (s) -> s.length).join(' ')


  log: (arg) ->
    @transmission.log this, arg
    return this


  @getNullQuery = -> @nullQuery ?= new NullQuery()

  getNullQuery: -> Query.getNullQuery()


  @createInitial = (transmission) ->
    new this(transmission,
      pass: Pass.createQueryDefault(), nesting: 0)


  @createNext = (prevQuery) ->
    new this(prevQuery.transmission, {
      pass: prevQuery.pass
      nesting:    prevQuery.nesting
    })


  @createNextConnection = (prevMessageOrQuery) ->
    new this(prevMessageOrQuery.transmission, {
      pass: prevMessageOrQuery.pass
      nesting:    prevMessageOrQuery.nesting - 1
    })


  @createForMerge = (mergedMessage) ->
    new this(mergedMessage.transmission, {
      pass: mergedMessage.pass
      nesting: mergedMessage.nesting
    })


  @createForSelect = (selectedMessage) ->
    new this(selectedMessage.transmission, {
      pass: selectedMessage.pass
      nesting: selectedMessage.nesting
    })


  @createForResponseMessage = (queuedMessage) ->
    pass = queuedMessage.pass.getForResponse()
    if pass?
      new this(queuedMessage.transmission, {
        pass
        nesting: queuedMessage.nesting
      })
    else
      @getNullQuery()



  constructor: (@transmission, opts = {}) ->
    {@pass, @nesting} = opts
    throw new Error "Missing nesting" unless @nesting?
    @passedLines = new FastSet()


  createNextQuery: ->
    Query.createNext(this)


  createQueryResponseMessage: (payload) ->
    @transmission.Message.createQueryResponse(this, payload)



  directionMatches: (direction) -> @pass.directionMatches(direction)


  type: 'query'

  communicationTypePriority: 0


  getUpdatePrecedence: ->
    @updatePrecedence ?=
      Precedence.createUpdate(@pass)


  wasDelivered: ->
    @delivered or @passedLines.length > 0


  tryQueryChannelNode: (channelNode) ->
    @transmission.tryQueryChannelNode(this, channelNode)


  sendToLine: (line) ->
    line.receiveQuery(this)
    return this


  getPassedLines: -> @passedLines


  addPassedLine: (line) ->
    @passedLines.add(line)
    return this


  _sendToNodePoint: (point) ->
    @log point
    if @transmission.tryAddCommunicationFor(this, point)
      point.receiveQuery(this)
    else
      @delivered = yes
    return this


  resendFromNodePoint: (point, channelNode) ->
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


  sendFromNodeToNodeTarget: (node, nodeTarget) ->
    @enqueueForSourceNode(node)
    @_sendToNodePoint(nodeTarget)


  enqueueForSourceNode: (@node) ->
    @transmission.enqueueCommunication(this)
    return this


  getQueuePrecedence: ->
    @queuePrecedence ?=
      Precedence.createQueue(@pass, @communicationTypePriority, @nesting)


  respond: ->
    unless @wasDelivered()
      @node.respondToQuery(this, @transmission.getPayloadFor(@node))
    return this
