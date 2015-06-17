'use strict'


assert = require 'assert'
MergedPayload = require '../payloads/merged'


class NullMessage
  sendFromNodeToNodeSource: -> this


module.exports = class Message

  @getNullMessage = -> @nullMessage ?= new NullMessage()

  inspect: ->
    [
      'M'
      'P:' + @precedence
      @direction.inspect()
      @wasDelivered and 'D' or ''
      @payload.inspect()
    ].filter( (s) -> s.length).join(' ')


  getNullMessage: -> Message.getNullMessage()


  constructor: (@transmission, @payload, opts = {}) ->
    assert(@payload, 'Message must have payload')
    {@precedence, @direction, @nesting, @sourceMessage} = opts


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


  createQueryForMerge: ->
    precedence = Math.ceil(@precedence)
    if precedence == 0
      precedence = -1
    @transmission.createQuery({
      precedence
      @direction
      @nesting
    })


  createNextMessage: (payload) ->
    @transmission.createMessage(payload, {@precedence, @direction, @nesting})


  createTransformedMessage: (payload) ->
    @transmission.createMessage(payload,
      {@precedence, @direction, @nesting, sourceMessage: this})


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
    @transmission.createMessage(payload,
      {precedence, @direction, nesting, sourceMessage: this})


  createResponseMessage: ->
    precedence = Math.ceil(@precedence) + 1
    if precedence == 1
      @transmission.createMessage(@payload,
        {precedence, direction: @direction.reverse(), @nesting})
    else
      @getNullMessage()


  createNextConnectionMessage: (payload) ->
    @transmission.createConnectionMessage(payload)


  markSourceMessageAsDelivered: ->
    if @sourceMessage?
      @sourceMessage.markSourceMessageAsDelivered()
    else
      @wasDelivered = yes
    return this


  getPayload: ->
    return @payload


  directionMatches: (direction) -> @direction.matches(direction)


  sendToLine: (line) ->
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveMessage(this)
    else
      line.receiveConnectionQuery(@createNextConnectionQuery())
    return this


  hasPrecedenceOver: (prev) ->
    not prev? or this.precedence > prev.precedence


  _sendToNodePoint: (point) ->
    unless @hasPrecedenceOver(@transmission.getMessageFor(point))
      @markSourceMessageAsDelivered()
      return this
    @transmission.addMessageFor(this, point)
    point.receiveMessage(this)
    return this


  sendToNodeTarget: (nodeTarget) -> @_sendToNodePoint(nodeTarget)


  sendToNode: (node) ->
    @markSourceMessageAsDelivered()
    node.routeMessage(this, @payload)
    return this


  sendFromNodeToNodeSource: (@node, nodeSource) ->
    @transmission.enqueue(this)
    @_sendToNodePoint(nodeSource)


  typeOrder: 1


  getQueueOrder: ->
    [@precedence, @typeOrder, @nesting]


  respond: ->
    @node.respondToMessage(this) unless @wasDelivered
    return this


  sendTransformedTo: (transform, target) ->
    copy = if transform?
      @createTransformedMessage(transform(@payload, @transmission))
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
