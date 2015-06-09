'use strict'


module.exports = class Query

  inspect: -> "Q #{@direction.inspect()}"


  constructor: (@transmission, opts = {}) ->
    @pathLength = opts.pathLength ? 0
    @precedence = opts.precedence
    @direction = opts.direction


  setDirection: (@direction) -> this


  createNextQuery: ->
    @transmission.createQuery({
      pathLength: @pathLength + 1
      @precedence
      @direction
    })


  createNextMessage: (payload) ->
    @transmission.createMessage(payload, {@precedence})


  sendToLine: (line) ->
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveQuery(this)
    else
      line.receiveConnectionQuery(@createNextQuery())
    return this


  hasPrecedenceOver: (prev) ->
    not prev? or this.precedence > prev.precedence


  _sendToNodePoint: (point) ->
    return this unless @hasPrecedenceOver(@transmission.getMessageFor(point))
    @transmission.addQueryFor(this, point)
    point.receiveQuery(this)
    return this


  sendToNodeSource: (nodeSource) -> @_sendToNodePoint(nodeSource)


  sendToNode: (node) ->
    node.routeQuery(this)
    return this


  sendToNodeTarget: (nodeTarget) -> @_sendToNodePoint(nodeTarget)


  shouldGetResponseAfter: (other) ->
    this.pathLength > other.pathLength


  enqueue: (@node) ->
    @transmission.enqueueQuery(this, @pathLength)
    return this


  respond: ->
    @node.respondToQuery(this) unless @wasSent
    return this


  sendToSourceAlongDirection: (source, direction) ->
    if @direction == direction
      @wasSent = yes
      source.receiveQuery(this)
    return this
