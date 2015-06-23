'use strict'


directions = require '../directions'


module.exports = class Query

  inspect: ->
    [
      'Q',
      'P:' + @precedence
      @direction.inspect(),
      @wasDelivered and 'D' or ''
    ].filter( (s) -> s.length).join(' ')


  @createInitial = (transmission) ->
    new this(transmission,
      {direction: directions.forward, precedence: 1, nesting: 0})


  @createNext = (prevQuery) ->
    new this(prevQuery.transmission, {
      precedence: prevQuery.precedence
      direction:  prevQuery.direction
      nesting:    prevQuery.nesting
    })


  @createNextConnection = (prevMessageOrQuery) ->
    new this(prevMessageOrQuery.transmission, {
      precedence: Math.ceil(prevMessageOrQuery.precedence) - 1
      direction:  prevMessageOrQuery.direction
      nesting:    prevMessageOrQuery.nesting - 1
    })


  @createForMerge = (prevMessage) ->
    precedence = Math.ceil(prevMessage.precedence)
    if precedence == 0
      precedence = -1
    new this(prevMessage.transmission, {
      precedence
      direction: prevMessage.direction
      nesting: prevMessage.nesting
    })



  constructor: (@transmission, opts = {}) ->
    {@precedence, @direction, @nesting} = opts


  createNextQuery: ->
    Query.createNext(this)


  createQueryResponseMessage: (payload) ->
    @transmission.Message.createQueryResponse(this, payload)



  directionMatches: (direction) -> @direction.matches(direction)


  hasPrecedenceOver: (prev) ->
    not prev? or [this.precedence, this.typeOrder] > [prev.precedence, prev.typeOrder]


  sendToLine: (line) ->
    if line.isConst() or not @hasPrecedenceOver(@transmission.getCommunicationFor(line))
      line.receiveOutgoingQuery(this)
    else
      line.receiveConnectionQuery(
        @transmission.Query.createNextConnection(this)
      )
    return this


  _sendToNodePoint: (point) ->
    if @hasPrecedenceOver(@transmission.getCommunicationFor(point))
      @transmission.addCommunicationFor(this, point)
      point.receiveQuery(this)
    else
      @wasDelivered = yes

    # unless @hasPrecedenceOver(@transmission.getMessageFor(point)) and
    #   @hasPrecedenceOver(@transmission.getQueryFor(point))
    #     @wasDelivered = yes
    #     return this
    # @transmission.addQueryFor(this, point)
    return this


  sendToNodeSource: (nodeSource) -> @_sendToNodePoint(nodeSource)


  sendToNode: (node) ->
    @wasDelivered = yes
    node.routeQuery(this)
    return this


  sendFromNodeToNodeTarget: (node, nodeTarget) ->
    @enqueueForSourceNode(node)
    @_sendToNodePoint(nodeTarget)


  enqueueForSourceNode: (@node) ->
    @transmission.enqueue(this)
    return this


  typeOrder: 0


  getQueueOrder: ->
    [@precedence, @typeOrder, @nesting]


  respond: ->
    @node.respondToQuery(this) unless @wasDelivered
    return this
