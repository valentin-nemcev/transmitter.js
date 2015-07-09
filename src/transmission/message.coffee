'use strict'


# MergedPayload = require '../payloads/merged'
Map = require 'collections/map'
Precedence = require './precedence'


class NullMessage
  sendFromNodeToNodeSource: -> this


module.exports = class Message

  inspect: ->
    [
      'M'
      @precedence.inspect()
      @getSourceNodes().map((n) -> n?.inspect() ? '-').join(', ')
      @wasDelivered and 'D' or ''
      @payload.inspect()
    ].filter( (s) -> s.length).join(' ')


  @getNullMessage = -> @nullMessage ?= new NullMessage()

  getNullMessage: -> Message.getNullMessage()


  @createInitial = (transmission, payload) ->
    new this(transmission, payload,
      precedence: Precedence.createMessageDefault(), nesting: 0)


  @createNext = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      precedence: prevMessage.precedence
      nesting:    prevMessage.nesting
    })


  @createQueryResponse = (queuedQuery, payload) ->
    new this(queuedQuery.transmission, payload, {
      precedence: queuedQuery.precedence
      nesting:    queuedQuery.nesting
    })


  @createMessageResponse = (queuedMessage, payload) ->
    precedence = queuedMessage.precedence.getFinal()
    if precedence?
      new this(queuedMessage.transmission, payload, {
        precedence
        nesting: queuedMessage.nesting
      })
    else
      @getNullMessage()


  @createTransformed = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      precedence:     prevMessage.precedence
      nesting:        prevMessage.nesting
      sourceMessages: [prevMessage]
    })


  @createMerged = (prevNodesToMessages) ->
    payloads = new Map(
      prevNodesToMessages.map (message, node) -> [node, message.payload]
    )
    prevMessages = prevNodesToMessages.values()
    precedence = Precedence.merge(
      prevMessages.map((message) -> message.precedence)
    )
    nesting = Math.max.apply(null,
      prevMessages.map((message) -> message.nesting)
    )
    prevMessage = prevMessages[0]
    new this(prevMessage.transmission, payloads, {
      precedence
      nesting
      sourceMessages: prevMessages
    })



  constructor: (@transmission, @payload, opts = {}) ->
    {@precedence, @nesting} = opts
    @sourceMessages = opts.sourceMessages ? []


  createNextMessage: (payload) ->
    Message.createNext(this, payload)


  createMessageResponseMessage: (payload) ->
    Message.createMessageResponse(this, payload)


  createNextConnectionMessage: (payload) ->
    @transmission.ConnectionMessage.createNext(this, payload)



  directionMatches: (direction) -> @precedence.directionMatches(direction)


  communicationTypeOrder: 1


  getPrecedence: ->
    [@precedence.level, @communicationTypeOrder]


  sendToLine: (line) ->
    if @transmission.tryQueryLine(this, line)
      line.receiveOutgoingMessage(this)
    return this


  _sendToNodePoint: (point) ->
    if @transmission.tryAddCommunicationFor(this, point)
      point.receiveMessage(this)
    else
      @markAsDelivered()
    return this


  sendToNodeTarget: (nodeTarget) -> @_sendToNodePoint(nodeTarget)


  sendToChannelNode: (node) ->
    node.routeMessage(this, @payload)
    return this


  sendToNode: (node) ->
    @markAsDelivered()
    node.routeMessage(this, @payload)
    return this


  sendFromNodeToNodeSource: (@node, nodeSource) ->
    @transmission.enqueueCommunication(this)
    @_sendToNodePoint(nodeSource)


  getQueueOrder: ->
    [@precedence.level, @communicationTypeOrder, @nesting]


  respond: ->
    @node.respondToMessage(this, @payload) unless @wasDelivered
    return this



  getSourceNode: ->
    switch @sourceMessages.length
      when 0 then @node
      when 1 then @sourceMessages[0].getSourceNode()
      else
        throw new Error('Expected single source node')


  getSourceNodes: ->
    if @sourceMessages.length
      @sourceMessages.map((message) -> message.getSourceNodes()).flatten()
    else
      [@node]



  markAsDelivered: ->
    if @sourceMessages.length
      for message in @sourceMessages
        message.markAsDelivered()
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
      comm = tr.getCommunicationFor(key.getNodeSource())
      return unless comm? and comm instanceof Message
      messages.push [key, comm]

    return messages


  # TODO: Refactor by using object instead of Map for cached messages, add
  # better check for keys
  sendMergedTo: (source, sourceKeys, target) ->
    cachedForMerge = @transmission.getCachedMessagesForMergeAt(source)

    if cachedForMerge.length is 0
      source.receiveQuery(@transmission.Query.createForMerge(this))

    cachedForMerge.set(this.getSourceNode(), this)

    if cachedForMerge.length == sourceKeys.length
      target.receiveMessage(Message.createMerged(cachedForMerge))

    return this
