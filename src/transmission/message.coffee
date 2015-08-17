'use strict'


{inspect} = require 'util'

Map = require 'collections/map'

Pass = require './pass'
Nesting = require './nesting'
Precedence = require './precedence'
SelectedMessage = require './selected_message'
MergedMessage = require './merged_message'


module.exports = class Message

  inspect: ->
    [
      'M'
      inspect @nesting
      inspect @pass
      @payload.inspect()
    ].filter( (s) -> s.length).join(' ')


  log: ->
    args = [this]
    args.push arg for arg in arguments
    @transmission.log args...
    return this


  @createInitial = (transmission, payload) ->
    new this(transmission, payload,
      pass: Pass.createMessageDefault(),
      nesting: Nesting.createInitial()
    )


  @createNext = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      pass: prevMessage.pass
      nesting: prevMessage.nesting
    })


  @createQueryResponse = (queuedQuery, payload) ->
    new this(queuedQuery.transmission, payload, {
      pass: queuedQuery.pass
      nesting: queuedQuery.nesting
    })


  @createTransformed = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      pass: prevMessage.pass
      nesting: prevMessage.nesting
    })


  @createMerged = (merged, payloads, {nesting}) ->
    new this(merged.transmission, payloads, {
      pass: merged.pass
      nesting
    })


  constructor: (@transmission, @payload, opts = {}) ->
    {@pass, @nesting} = opts
    throw new Error "Missing payload" unless @payload?
    throw new Error "Missing nesting" unless @nesting?


  createNextMessage: (payload) ->
    Message.createNext(this, payload)


  createQueryForResponseMessage: ->
    @transmission.Query.createForResponseMessage(this)


  createNextConnectionMessage: (channelNode) ->
    @transmission.ConnectionMessage.createNext(this, channelNode)



  directionMatches: (direction) -> @pass.directionMatches(direction)


  type: 'message'

  communicationTypePriority: 1


  join: (comm) ->
    if this.pass.equals(comm.pass)
      Nesting.equalize [this.nesting, comm.nesting]
    return this


  getUpdatePrecedence: ->
    @updatePrecedence ?=
      Precedence.createUpdate(@pass)


  getSelectPrecedence: ->
    @selectPrecedence ?= Precedence.createSelect(@payload.getPriority())


  tryQueryChannelNode: (channelNode) ->
    @transmission.tryQueryChannelNode(this, channelNode)


  sendToLine: (line) ->
    @log line
    line.receiveMessage(this)
    return this


  _sendToNodePoint: (point) ->
    @log point
    existingQuery = @transmission.getCommunicationFor('query', @pass, point)
    existingQuery?.join(this)
    existing = @transmission.getCommunicationFor('message', @pass, point)
    existing ?= @transmission.getCommunicationFor('message', @pass.getNext(), point)
    if existing?
      existing.join(this)
    else
      @transmission.addCommunicationFor(this, point)
      point.receiveMessage(this)
    return this


  resendFromNodePoint: (point, channelNode, connectionMessage) ->
    @nesting = connectionMessage.nesting
    point.resendMessage(this, channelNode)
    return this


  sendToNodeTarget: (nodeTarget) ->
    @_sendToNodePoint(nodeTarget)


  sendToChannelNode: (node) ->
    @log node
    existingQuery = @transmission.getCommunicationFor('query', @pass, node)
    existingQuery?.join(this)
    existing = @transmission.getCommunicationFor('message', @pass, node)
    existing ?= @transmission.getCommunicationFor('message', @pass.getNext(), node)
    if existing?
      existing.join(this)
    else
      @transmission.addCommunicationFor(this, node)
      node.routeMessage(this, @payload)
    return this


  sendToNode: (node) ->
    @log node
    node.routeMessage(this, @payload)
    return this


  sendFromNodeToNodeSource: (@sourceNode, nodeSource) ->
    @transmission.enqueueCommunication(this)
    @transmission.addPayloadFor(@payload, @sourceNode)
    @_sendToNodePoint(nodeSource)


  getQueuePrecedence: ->
    @queuePrecedence ?=
      Precedence.createQueue(@pass, @communicationTypePriority, @nesting)


  respond: ->
    @log 'respond', @sourceNode
    @sourceNode.respondToMessage(this)
    return this



  sendTransformedTo: (transform, target) ->
    copy = if transform?
      payload = if (targetPayload = target.getPayload())?
        transform(@payload, targetPayload, @transmission)
        targetPayload
      else
        transform(@payload, @transmission)
      Message.createTransformed(this, payload)
    else
      this
    target.receiveMessage(copy)
    return this


  sendSeparatedTo: (targets) ->
    targets.forEach (target, node) =>
      msg = Message.createTransformed(this, @payload.get(node))
      target.receiveMessage(msg)
    return this


  sendMergedTo: (source, target) ->
    MergedMessage
      .getOrCreate(source, @transmission, @pass, @nesting)
      .receiveMessageFrom(this, @sourceNode)

    return this


  sendToSelectingNodeTarget: (line, nodeTarget) ->
    SelectedMessage
      .getOrCreate(nodeTarget, @transmission, @pass, @nesting)
      .receiveMessageFrom(this, line)

    return this
