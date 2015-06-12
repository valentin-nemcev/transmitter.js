'use strict'


assert = require 'assert'
MergedPayload = require '../payloads/merged'


module.exports = class Message

  inspect: -> "M #{@payload.inspect()}"


  constructor: (@transmission, @payload, opts = {}) ->
    assert(@payload, 'Message must have payload')
    {@precedence, @direction, @nesting} = opts


  createNextConnectionQuery: -> @createNextQuery(-1)


  createNextQuery: (nestingDelta = 0) ->
    @transmission.createQuery({
      @precedence,
      @direction,
      nesting: @nesting + nestingDelta
    })


  createQueryForMerge: ->
    @transmission.createQuery({
      precedence: Math.ceil(@precedence) - 1,
      @direction,
      @nesting
    })


  createNextMessage: (payload) ->
    @transmission.createMessage(payload, {@precedence, @direction, @nesting})


  createMergedMessage: (messages) ->
    payload = new MergedPayload(
      messages.map ([key, message]) -> [key, message.getPayload()]
    )
    precedence = messages
      .map(([key, message]) -> message.precedence)
      .reduce((a, b) -> a + b) /
        messages.length
    nesting = Math.max.apply(null,
      messages.map(([key, message]) -> message.nesting)
    )
    @transmission.createMessage(payload, {precedence, @direction, nesting})


  createResponseMessage: ->
    precedence = Math.min(1, Math.floor(@precedence) + 1)
    @transmission.createMessage(@payload,
      {precedence, direction: @direction.reverse(), @nesting})


  createNextConnectionMessage: (payload) ->
    @transmission.createConnectionMessage(payload)


  getPayload: ->
    return @payload


  sendToLine: (line) ->
    if not line.directionMatches(@direction)
      return this
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveMessage(this)
    else
      line.receiveConnectionQuery(@createNextConnectionQuery())
    return this


  hasPrecedenceOver: (prev) ->
    not prev? or this.precedence > prev.precedence


  _sendToNodePoint: (point) ->
    unless @hasPrecedenceOver(@transmission.getMessageFor(point))
      @wasRelayed = yes
      return this
    @transmission.addMessageFor(this, point)
    point.receiveMessage(this)
    return this


  sendToNodeTarget: (nodeTarget) -> @_sendToNodePoint(nodeTarget)


  sendToNode: (node) ->
    @wasRelayed = yes
    node.routeMessage(this, @payload)
    return this


  sendToNodeSource: (nodeSource) -> @_sendToNodePoint(nodeSource)


  typeOrder: 1


  getQueueOrder: ->
    [@precedence, @typeOrder, @nesting]


  enqueueForSourceNode: (@node) ->
    @transmission.enqueue(this)
    return this


  respond: ->
    @node.respondToMessage(this) unless @wasRelayed
    return this


  sendTransformedTo: (transform, target) ->
    copy = if transform?
      @createNextMessage(transform(@payload, @transmission))
    else
      this
    target.receiveMessage(copy)
    return this


  getMessagesToMerge = (tr, sourceKeys) ->
    messages = []
    for key in sourceKeys
      message = tr.getMessageFor(key.getNodeSource())
      return unless message?
      messages.push [key, message]

    return messages


  sendMergedTo: (sourceKeys, target) ->
    if (messages = getMessagesToMerge(@transmission, sourceKeys))?
      target.receiveMessage(@createMergedMessage(messages))
    return this


  sendQueryForMerge: (source) ->
    source.receiveQuery(@createQueryForMerge())
    return this
