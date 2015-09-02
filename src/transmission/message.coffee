'use strict'


{inspect} = require 'util'

Map = require 'collections/map'

Pass = require './pass'
Precedence = require './precedence'
MergedMessage = require './merged_message'


module.exports = class Message

  inspect: ->
    [
      'M'
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
    )


  @createNext = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      pass: prevMessage.pass
    })


  @createQueryResponse = (queuedQuery, payload) ->
    new this(queuedQuery.transmission, payload, {
      pass: queuedQuery.pass
    })


  @createTransformed = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      pass: prevMessage.pass
    })


  @createMerged = (merged, payloads) ->
    new this(merged.transmission, payloads, {
      pass: merged.pass
    })


  constructor: (@transmission, @payload, opts = {}) ->
    {@pass} = opts
    throw new Error "Missing payload" unless @payload?


  createNextMessage: (payload) ->
    Message.createNext(this, payload)


  createNextConnectionMessage: (channelNode) ->
    @transmission.ConnectionMessage.createNext(this, channelNode)



  directionMatches: (direction) -> @pass.directionMatches(direction)


  type: 'message'

  communicationTypePriority: 1


  join: (comm) ->
    return this


  getUpdatePrecedence: ->
    @updatePrecedence ?=
      Precedence.createUpdate(@pass)


  getSelectPrecedence: ->
    @selectPrecedence ?= Precedence.createSelect(@payload.getPriority())


  tryQueryChannelNode: (channelNode) ->
    @transmission.tryQueryChannelNode(this, channelNode)


  addPassedChannelNode: (channelNode) ->
    return this


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


  sendToNodeTarget: (nodeTarget) ->
    @transmission.SelectedMessage
      .getOrCreate(this, nodeTarget)
      .joinInitialMessage(this)
    return this


  sendToSelectingNodeTarget: (line, nodeTarget) ->
    @transmission.SelectedMessage
      .getOrCreate(this, nodeTarget)
      .joinMessageFrom(this, line)
    return this


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
      Precedence.createQueue(@pass, @communicationTypePriority)


  readyToRespond: -> yes


  respond: ->
    @log 'respond', @sourceNode
    @transmission.SelectedMessage
      .joinMessageForResponse(this, @sourceNode.getNodeTarget())
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
      .getOrCreate(this, source)
      .receiveMessageFrom(this, @sourceNode)

    return this
