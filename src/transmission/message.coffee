'use strict'


MergedPayload = require '../payloads/merged'
directions = require '../directions'


class NullMessage
  sendFromNodeToNodeSource: -> this


module.exports = class Message

  inspect: ->
    [
      'M'
      'P:' + @precedence
      @direction.inspect()
      @getSourceNodes().map((n) -> n.inspect()).join(' ')
      @wasDelivered and 'D' or ''
      @payload.inspect()
    ].filter( (s) -> s.length).join(' ')


  @getNullMessage = -> @nullMessage ?= new NullMessage()

  getNullMessage: -> Message.getNullMessage()


  @createInitial = (transmission, payload) ->
    new this(transmission, payload,
      direction: directions.backward, precedence: 0, nesting: 0)


  @createNext = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      precedence: prevMessage.precedence
      direction:  prevMessage.direction
      nesting:    prevMessage.nesting
    })


  @createQueryResponse = (queuedQuery, payload) ->
    new this(queuedQuery.transmission, payload, {
      precedence: queuedQuery.precedence
      direction:  queuedQuery.direction
      nesting:    queuedQuery.nesting
    })


  @createMessageResponse = (queuedMessage, payload) ->
    precedence = Math.ceil(queuedMessage.precedence) + 1
    if precedence == 1
      new this(queuedMessage.transmission, payload, {
        precedence
        direction: queuedMessage.direction.reverse()
        nesting: queuedMessage.nesting
      })
    else
      @getNullMessage()


  @createTransformed = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      precedence:     prevMessage.precedence
      direction:      prevMessage.direction
      nesting:        prevMessage.nesting
      sourceMessages: [prevMessage]
    })


  @createMerged = (prevMessages) ->
    payload = new MergedPayload(
      prevMessages.map ([key, message]) -> [key, message.payload]
    )
    precedence = prevMessages
      .map(([key, message]) -> message.precedence)
      .reduce((a, b) -> a + b) /
        prevMessages.length
    nesting = Math.max.apply(null,
      prevMessages.map(([key, message]) -> message.nesting)
    )
    prevMessage = prevMessages[0][1]
    new this(prevMessage.transmission, payload, {
      precedence
      direction: prevMessage.direction #TODO
      nesting
      sourceMessages: prevMessages.map ([key, message]) -> message
    })



  constructor: (@transmission, @payload, opts = {}) ->
    {@precedence, @direction, @nesting} = opts
    @sourceMessages = opts.sourceMessages ? []


  createNextMessage: (payload) ->
    Message.createNext(this, payload)


  createMessageResponseMessage: (payload) ->
    Message.createMessageResponse(this, payload)


  createNextConnectionMessage: (payload) ->
    @transmission.ConnectionMessage.createNext(this, payload)



  directionMatches: (direction) -> @direction.matches(direction)


  sendToLine: (line) ->
    # TODO: Check connection message precedence
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveMessage(this)
    else
      line.receiveConnectionQuery(
        @transmission.Query.createNextConnection(this)
      )
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


  sendToChannelNode: (node) ->
    node.routeMessage(this, @payload)
    return this


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



  getSourceNodes: ->
    if @sourceMessages.length
      sourceNodes = []
      for message in @sourceMessages
        sourceNodes.push @sourceMessages.getSourceNodes()...
      sourceNodes
    else
      [@node]


  markSourceMessageAsDelivered: ->
    if @sourceMessages.length
      for message in @sourceMessages
        message.markSourceMessageAsDelivered()
    else
      @wasDelivered = yes
    return this


  sendTransformedTo: (transform, target) ->
    copy = if transform?
      Message.createTransformed(this, transform(@payload, @transmission))
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
      target.receiveMessage(Message.createMerged(messages))
    return this


  sendQueryForMerge: (source) ->
    source.receiveQuery(@transmission.Query.createForMerge(this))
    return this
