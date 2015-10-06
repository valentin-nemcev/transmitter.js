'use strict'


{inspect} = require 'util'

Precedence = require './precedence'
SeparatedMessage = require './separated_message'


module.exports = class TargetMessage

  inspect: ->
    [
      'TM'
      inspect @pass
      @payload.inspect()
    ].filter( (s) -> s.length).join(' ')


  log: ->
    args = [this]
    args.push arg for arg in arguments
    @transmission.log args...
    return this


  @create = (prevMessage, transform) ->
    new this(prevMessage, transform, null)


  createSeparate: (prevMessage, payload) ->
    new TargetMessage(prevMessage, null, payload)


  constructor: (@sourceMessage, @transform, @payload) ->
    {@transmission, @pass} = @sourceMessage


  createNextConnectionMessage: (channelNode) ->
    @transmission.ConnectionMessage.createNext(this, channelNode)


  # TODO: Refactor
  getSelectPrecedence: ->
    @selectPrecedence ?= Precedence.createSelect(@getPriority())


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
    node.routeMessage(this, @getPayload())
    return this


  joinSeparatedMessage: (target) ->
    SeparatedMessage
      .getOrCreate(this, target)
      .joinMessage(this)

    return this


  getPriority: ->
    @getPayload().fixedPriority ? @sourceMessage.getPriority()


  getPayload: (args...) ->
    @payload ?= if @transform?
      args = [@sourceMessage.getPayload(), args...]
      @transform.call(null, args..., @transmission)
    else if @payload?
      @payload
    else
      @sourceMessage.getPayload()
