'use strict'


Map = require 'collections/map'
Precedence = require './precedence'

SelectedMessage = require './selected_message'


module.exports = class Message

  inspect: ->
    [
      'M'
      @precedence.inspect()
      # @getSourceNodes().map((n) -> n?.inspect() ? '-').join(', ')
      @payload.inspect()
    ].filter( (s) -> s.length).join(' ')


  log: ->
    @transmission.log this, arguments...
    return this


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


  @createTransformed = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      precedence:     prevMessage.precedence
      nesting:        prevMessage.nesting
      sourceMessages: [prevMessage]
    })


  @createMerged = (prevNodesToMessages) ->
    prevMessages = prevNodesToMessages.values()
    precedence = Precedence.merge(
      prevMessages.map((message) -> message.precedence)
    )
    return null unless precedence?

    payloads = new Map(
      prevNodesToMessages.map (message, node) -> [node, message.payload]
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
    throw new Error "Missing payload" unless @payload?


  createNextMessage: (payload) ->
    Message.createNext(this, payload)


  createQueryForResponseMessage: ->
    @transmission.Query.createForResponseMessage(this)


  createNextConnectionMessage: (channelNode) ->
    @transmission.ConnectionMessage.createNext(this, channelNode)



  directionMatches: (direction) -> @precedence.directionMatches(direction)


  communicationTypeOrder: 1


  getPrecedence: ->
    [@precedence.level, @communicationTypeOrder]


  getPayloadPriority: -> @payload.getPriority()


  tryQueryChannelNode: (channelNode) ->
    @transmission.tryQueryChannelNode(this, channelNode)


  sendToLine: (line) ->
    @log line
    line.receiveMessage(this)
    return this


  _sendToNodePoint: (point) ->
    if @transmission.tryAddCommunicationFor(this, point)
      point.receiveMessage(this)
    return this


  resendFromNodePoint: (point, channelNode) ->
    point.resendMessage(this, channelNode)
    return this


  sendToNodeTarget: (nodeTarget) ->
    @log nodeTarget
    @_sendToNodePoint(nodeTarget)


  sendToChannelNode: (node) ->
    @log node
    @transmission.tryAddCommunicationFor(this, node) \
      or throw new Error("Can't send message to same channel node twice")
    node.routeMessage(this, @payload)
    return this


  sendToNode: (node) ->
    @log node
    node.routeMessage(this, @payload)
    return this


  sendFromNodeToNodeSource: (@node, nodeSource) ->
    @log nodeSource
    @transmission.enqueueCommunication(this)
    @transmission.addPayloadFor(@payload, @node)
    @_sendToNodePoint(nodeSource)


  getQueueOrder: ->
    [@precedence.level, @communicationTypeOrder, @nesting]


  respond: ->
    @node.respondToMessage(this)
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
    cachedForMerge = @transmission.getCachedMessage(source)
    unless cachedForMerge?
      cachedForMerge = new Map()
      @transmission.setCachedMessage(source, cachedForMerge)

    if cachedForMerge.length is 0
      source.receiveQuery(@transmission.Query.createForMerge(this))

    cachedForMerge.set(this.getSourceNode(), this)

    # TODO: Compare contents
    if cachedForMerge.length == sourceKeys.length
      merged = Message.createMerged(cachedForMerge)
      target.receiveMessage(merged) if merged?

    return this


  sendToMergingNodeTarget: (line, nodeTarget) ->
    # TODO: More consistent creation method
    cachedForMerge = @transmission.getCachedMessage(nodeTarget)
    if not cachedForMerge? or @precedence.level > cachedForMerge.precedence.level
      cachedForMerge = SelectedMessage.create(@transmission, {@precedence})
      @transmission.setCachedMessage(nodeTarget, cachedForMerge)


    cachedForMerge.receiveMessageFrom(this, line)

    cachedForMerge.sendToNodeTarget(nodeTarget)

    return this
