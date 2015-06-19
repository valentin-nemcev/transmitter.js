'use strict'


module.exports = class Query

  inspect: ->
    [
      'Q',
      'P:' + @precedence
      @direction.inspect(),
      @wasDelivered and 'D' or ''
    ].filter( (s) -> s.length).join(' ')


  constructor: (@transmission, opts = {}) ->
    {@precedence, @direction, @nesting} = opts


  createNextConnectionQuery: ->
    @transmission.createQuery({
      precedence: Math.ceil(@precedence) - 1
      @direction
      nesting: @nesting - 1
    })


  createNextQuery: ->
    @transmission.createQuery({
      @precedence
      @direction
      @nesting
    })


  createNextMessage: (payload) ->
    @transmission.createMessage(payload, {@precedence, @direction, @nesting})


  directionMatches: (direction) -> @direction.matches(direction)


  sendToLine: (line) ->
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
        @wasDelivered = yes
        return this
    @transmission.addQueryFor(this, point)
    point.receiveQuery(this)
    return this


  sendToNodeSource: (nodeSource) -> @_sendToNodePoint(nodeSource)


  sendToNode: (node) ->
    @wasDelivered = yes
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
    @node.respondToQuery(this) unless @wasDelivered
    return this
