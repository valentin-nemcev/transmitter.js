'use strict'


module.exports = class Query

  inspect: -> "Q #{@direction.inspect()}"


  constructor: (@transmission, opts = {}) ->
    {@precedence, @direction, @nesting} = opts


  createNextConnectionQuery: -> @createNextQuery(-1)


  createNextQuery: (nestingDelta = 0) ->
    @transmission.createQuery({
      @precedence
      @direction
      nesting: @nesting + nestingDelta
    })


  createNextMessage: (payload) ->
    @transmission.createMessage(payload, {@precedence, @direction, @nesting})


  sendToLine: (line) ->
    if not line.directionMatches(@direction)
      return this
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveQuery(this)
    else
      line.receiveConnectionQuery(@createNextConnectionQuery())
    return this


  hasPrecedenceOver: (prev) ->
    not prev? or this.precedence > prev.precedence


  _sendToNodePoint: (point) ->
    unless @hasPrecedenceOver(@transmission.getMessageFor(point)) and
      @hasPrecedenceOver(@transmission.getQueryFor(point))
        @wasRelayed = yes
        return this
    @transmission.addQueryFor(this, point)
    point.receiveQuery(this)
    return this


  sendToNodeSource: (nodeSource) -> @_sendToNodePoint(nodeSource)


  sendToNode: (node) ->
    @wasRelayed = yes
    node.routeQuery(this)
    return this


  sendToNodeTarget: (nodeTarget) -> @_sendToNodePoint(nodeTarget)


  typeOrder: 0


  getQueueOrder: ->
    [@precedence, @typeOrder, @nesting]


  enqueueForSourceNode: (@node) ->
    @transmission.enqueue(this)
    return this


  respond: ->
    @node.respondToQuery(this) unless @wasRelayed
    return this
