'use strict'


Precedence = require './precedence'


module.exports = class Query

  inspect: ->
    [
      'Q',
      @precedence.inspect()
      @node?.inspect() ? ''
      @wasDelivered and 'D' or ''
    ].filter( (s) -> s.length).join(' ')


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


  @createForMerge = (prevMessage) ->
    new this(prevMessage.transmission, {
      precedence: prevMessage.precedence.getPrevious()
      nesting: prevMessage.nesting
    })



  constructor: (@transmission, opts = {}) ->
    {@precedence, @nesting} = opts


  createNextQuery: ->
    Query.createNext(this)


  createQueryResponseMessage: (payload) ->
    @transmission.Message.createQueryResponse(this, payload)



  directionMatches: (direction) -> @precedence.directionMatches(direction)


  communicationTypeOrder: 0


  getPrecedence: ->
    [@precedence.level, @communicationTypeOrder]


  sendToLine: (line) ->
    if @transmission.tryQueryLine(this, line)
      line.receiveOutgoingQuery(this)
    return this


  _sendToNodePoint: (point) ->
    if @transmission.tryAddCommunicationFor(this, point)
      point.receiveQuery(this)
    else
      @markAsDelivered()
    return this


  sendToNodeSource: (nodeSource) -> @_sendToNodePoint(nodeSource)


  sendToNode: (node) ->
    @markAsDelivered()
    node.routeQuery(this)
    return this


  sendFromNodeToNodeTarget: (node, nodeTarget) ->
    @enqueueForSourceNode(node)
    @_sendToNodePoint(nodeTarget)


  enqueueForSourceNode: (@node) ->
    @transmission.enqueueCommunication(this)
    return this


  getQueueOrder: ->
    [@precedence.level, @communicationTypeOrder, @nesting]


  respond: ->
    @node.respondToQuery(this) unless @wasDelivered
    return this



  markAsDelivered: ->
    @wasDelivered = yes
    return this
