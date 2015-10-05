'use strict'


{inspect} = require 'util'

Map = require 'collections/map'

Pass = require './pass'
Precedence = require './precedence'
MergedMessage = require './merged_message'
SeparatedMessage = require './separated_message'


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


  @createNext = (prevMessage, payload, priority) ->
    new this(prevMessage.transmission, prevMessage.pass, payload, priority)


  constructor: (@transmission, @pass, @payload, @priority) ->
    throw new Error "Missing payload" unless @payload?


  createNextConnectionMessage: (channelNode) ->
    @transmission.ConnectionMessage.createNext(this, channelNode)



  directionMatches: (direction) -> @pass.directionMatches(direction)


  getSelectPrecedence: ->
    @selectPrecedence ?= Precedence.createSelect(@getPriority())


  getPriority: ->
    @payload.fixedPriority ? @priority


  getPayload: -> @payload


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


  sendTransformedTo: (transform, target) ->
    transformed = if transform?
      payload = transform(@payload, @transmission)
      Message.createNext(this, payload, @getPriority())
    else
      this
    target.receiveMessage(transformed)
    return this


  joinSeparatedMessage: (target) ->
    SeparatedMessage
      .getOrCreate(this, target)
      .joinMessage(this)

    return this


  joinMergedMessage: (source) ->
    MergedMessage
      .getOrCreate(this, source)
      .joinMessageFrom(this, @sourceNode)

    return this
