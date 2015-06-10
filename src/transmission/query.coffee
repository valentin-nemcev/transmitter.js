'use strict'


module.exports = class Query

  inspect: -> "Q #{@direction.inspect()}"


  constructor: (@transmission, opts = {}) ->
    @pathLength = opts.pathLength ? 0
    {@precedence, @direction, @nesting} = opts


  createNextConnectionQuery: -> @createNextQuery(-1)


  createNextQuery: (nestingDelta = 0) ->
    @transmission.createQuery({
      pathLength: @pathLength + 1
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
    return this unless @hasPrecedenceOver(@transmission.getMessageFor(point))
    @transmission.addQueryFor(this, point)
    point.receiveQuery(this)
    return this


  sendToNodeSource: (nodeSource) -> @_sendToNodePoint(nodeSource)


  sendToNode: (node) ->
    @wasRelayed = yes
    node.routeQuery(this)
    return this


  sendToNodeTarget: (nodeTarget) -> @_sendToNodePoint(nodeTarget)


  shouldGetResponseAfter: (other) ->
    if this.nesting > other.nesting then yes
    else if this.nesting == other.nesting
      this.pathLength > other.pathLength
    else
      no


  enqueueForSourceNode: (@node) ->
    @wasRelayed = no
    @transmission.enqueueQuery(this, @pathLength)
    return this


  respond: ->
    @node.respondToQuery(this) unless @wasRelayed
    return this
