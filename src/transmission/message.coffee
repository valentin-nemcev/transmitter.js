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


  getSelectPrecedence: ->
    @selectPrecedence ?= Precedence.createSelect(@payload.getPriority())


  sendToLine: (line) ->
    @log line
    line.receiveMessage(this)
    return this


  sendToNodeTarget: (line, nodeTarget) ->
    @transmission.JointMessage
      .getOrCreate(this, {nodeTarget})
      .joinMessageFrom(this, line)
    return this


  sendToChannelNode: (node) ->
    @log node
    existing = @transmission.getCommunicationFor(@pass, node)
    existing ?= @transmission.getCommunicationFor(@pass.getNext(), node)
    if existing?
      throw new Error "Message already sent to #{inspect node}. " \
        + "Previous: #{inspect existing}, " \
        + "current: #{inspect this}"
    @transmission.addCommunicationFor(this, node)
    node.routeMessage(this, @payload)
    return this


  readyToRespond: -> false


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
