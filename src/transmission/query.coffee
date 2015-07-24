'use strict'


Precedence = require './precedence'
FastSet = require 'collections/fast-set'


class NullQuery
  sendFromNodeToNodeTarget: -> this
  enqueueForSourceNode: -> this


module.exports = class Query

  inspect: ->
    [
      'Q',
      @precedence.inspect()
      @wasDelivered() and 'D' or ''
    ].filter( (s) -> s.length).join(' ')


  log: ->
    @transmission.log this, arguments...
    return this


  @getNullQuery = -> @nullQuery ?= new NullQuery()

  getNullQuery: -> Query.getNullQuery()


  @createInitial = (transmission) ->
    new this(transmission,
      precedence: Precedence.createQueryDefault(), nesting: 0)


  @createNext = (prevQuery) ->
    new this(prevQuery.transmission, {
      precedence: prevQuery.precedence
      nesting:    prevQuery.nesting
    })


  @createNextConnection = (prevMessageOrQuery) ->
    new this(prevMessageOrQuery.transmission, {
      precedence: prevMessageOrQuery.precedence.getPrevious()
      nesting:    prevMessageOrQuery.nesting - 1
    })


  @createForMerge = (mergedMessage) ->
    new this(mergedMessage.transmission, {
      precedence: mergedMessage.precedence.getPrevious()
      nesting: mergedMessage.nesting
    })


  @createForSelect = (selectedMessage) ->
    new this(selectedMessage.transmission, {
      precedence: selectedMessage.precedence.getPrevious()
      nesting: selectedMessage.nesting
    })


  @isForSelect = (query, selectedMessage) ->
    query? \
      and query instanceof this \
      and query.precedence.direction == selectedMessage.precedence.direction


  @createForResponseMessage = (queuedMessage) ->
    precedence = queuedMessage.precedence.getFinal()
    if precedence?
      new this(queuedMessage.transmission, {
        precedence
        nesting: queuedMessage.nesting
      })
    else
      @getNullQuery()



  constructor: (@transmission, opts = {}) ->
    {@precedence, @nesting} = opts
    @linesPassed = new FastSet()


  createNextQuery: ->
    Query.createNext(this)


  createQueryResponseMessage: (payload) ->
    @transmission.Message.createQueryResponse(this, payload)



  directionMatches: (direction) -> @precedence.directionMatches(direction)


  communicationTypeOrder: 0


  getPrecedence: ->
    [@precedence.level, @communicationTypeOrder]


  wasDelivered: ->
    @delivered or @linesPassed.length > 0


  tryQueryChannelNode: (channelNode) ->
    @transmission.tryQueryChannelNode(this, channelNode)


  sendToLine: (line) ->
    @log line
    line.receiveQuery(this)
    return this


  getPassedLines: -> @linesPassed


  addPassedLine: (line) ->
    @linesPassed.add(line)
    return this


  _sendToNodePoint: (point) ->
    if @transmission.tryAddCommunicationFor(this, point)
      point.receiveQuery(this)
    else
      @delivered = yes
    return this


  resendFromNodePoint: (point, channelNode) ->
    point.resendQuery(this, channelNode)
    return this


  sendToNodeSource: (nodeSource) ->
    @log nodeSource
    @_sendToNodePoint(nodeSource)


  sendToChannelNode: (node) ->
    @log node
    node.receiveQuery(this)
    return this


  sendToNode: (node) ->
    @log node
    node.routeQuery(this)
    return this


  sendToNodeTarget: (nodeTarget) ->
    @log nodeTarget
    @_sendToNodePoint(nodeTarget)


  sendFromNodeToNodeTarget: (node, nodeTarget) ->
    @log nodeTarget
    @enqueueForSourceNode(node)
    @_sendToNodePoint(nodeTarget)


  enqueueForSourceNode: (@node) ->
    @transmission.enqueueCommunication(this)
    return this


  getQueueOrder: ->
    [@precedence.level, @communicationTypeOrder, @nesting]


  respond: ->
    unless @wasDelivered()
      @node.respondToQuery(this, @transmission.getPayloadFor(@node))
    return this
