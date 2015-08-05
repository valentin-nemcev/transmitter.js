'use strict'


{inspect} = require 'util'

Map = require 'collections/map'

Pass = require './pass'
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


  log: (arg) ->
    @transmission.log this, arg
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
    if @transmission.tryAddCommunicationFor(this, point)
      point.receiveMessage(this)
    return this


  resendFromNodePoint: (point, channelNode) ->
    point.resendMessage(this, channelNode)
    return this


  sendToNodeTarget: (nodeTarget) ->
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


  sendFromNodeToNodeSource: (@sourceNode, nodeSource) ->
    @transmission.enqueueCommunication(this)
    @transmission.addPayloadFor(@payload, @sourceNode)
    @_sendToNodePoint(nodeSource)


  getQueuePrecedence: ->
    @queuePrecedence ?=
      Precedence.createQueue(@pass, @communicationTypePriority, @nesting)


  respond: ->
    @sourceNode.respondToMessage(this)
    return this



  sendTransformedTo: (transform, target) ->
    copy = if transform?
      Message.createTransformed(this, transform(@payload, @transmission))
    else
      this
    target.receiveMessage(copy)
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
