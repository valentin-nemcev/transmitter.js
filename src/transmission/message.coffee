'use strict'


Map = require 'collections/map'
Pass = require './pass'
Precedence = require './precedence'

SelectedMessage = require './selected_message'


module.exports = class Message

  inspect: ->
    [
      'M'
      @pass.inspect()
      # @getSourceNodes().map((n) -> n?.inspect() ? '-').join(', ')
      @payload.inspect()
    ].filter( (s) -> s.length).join(' ')


  log: ->
    @transmission.log this, arguments...
    return this


  @createInitial = (transmission, payload) ->
    new this(transmission, payload,
      pass: Pass.createMessageDefault(), nesting: 0)


  @createNext = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      pass: prevMessage.pass
      nesting:    prevMessage.nesting
    })


  @createQueryResponse = (queuedQuery, payload) ->
    new this(queuedQuery.transmission, payload, {
      pass: queuedQuery.pass
      nesting:    queuedQuery.nesting
    })


  @createTransformed = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      pass:     prevMessage.pass
      nesting:        prevMessage.nesting
      sourceMessages: [prevMessage]
    })


  @createMerged = (prevNodesToMessages) ->
    prevMessages = prevNodesToMessages.values()
    pass = Pass.merge(
      prevMessages.map((message) -> message.pass)
    )
    return null unless pass?

    payloads = new Map(
      prevNodesToMessages.map (message, node) -> [node, message.payload]
    )
    nesting = Math.max.apply(null,
      prevMessages.map((message) -> message.nesting)
    )
    prevMessage = prevMessages[0]
    new this(prevMessage.transmission, payloads, {
      pass
      nesting
      sourceMessages: prevMessages
    })


  constructor: (@transmission, @payload, opts = {}) ->
    {@pass, @nesting} = opts
    @sourceMessages = opts.sourceMessages ? []
    throw new Error "Missing payload" unless @payload?


  createNextMessage: (payload) ->
    Message.createNext(this, payload)


  createQueryForResponseMessage: ->
    @transmission.Query.createForResponseMessage(this)


  createNextConnectionMessage: (channelNode) ->
    @transmission.ConnectionMessage.createNext(this, channelNode)



  directionMatches: (direction) -> @pass.directionMatches(direction)


  communicationTypePriority: 1


  getUpdatePrecedence: ->
    @updatePrecedence ?=
      Precedence.createUpdate(@pass, @communicationTypePriority)


  getSelectPrecedence: ->
    @selectPrecedence ?= Precedence.createSelect(@payload.getPriority())


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


  getQueuePrecedence: ->
    @queuePrecedence ?=
      Precedence.createQueue(@pass, @communicationTypePriority, @nesting)


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
    merged = @transmission.getCachedMessage(source)
    unless merged?
      merged = new Map()
      @transmission.setCachedMessage(source, merged)

    if merged.length is 0
      source.receiveQuery(@transmission.Query.createForMerge(this))

    merged.set(this.getSourceNode(), this)

    # TODO: Compare contents
    if merged.length == sourceKeys.length
      merged = Message.createMerged(merged)
      target.receiveMessage(merged) if merged?

    return this


  sendToSelectingNodeTarget: (line, nodeTarget) ->
    # TODO: More consistent creation method
    selected = @transmission.getCachedMessage(nodeTarget)
    if not selected? \
      or @getUpdatePrecedence().compare(selected.getUpdatePrecedence()) > 0
        selected = SelectedMessage.create(@transmission, {@pass})
        @transmission.setCachedMessage(nodeTarget, selected)

    selected.receiveMessageFrom(this, line)

    selected.sendToNodeTarget(nodeTarget)

    return this
