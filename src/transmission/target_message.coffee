'use strict'


{inspect} = require 'util'


module.exports = class TargetMessage

  inspect: ->
    [
      'TM'
      inspect @pass
      "P:#{@getPriority()}"
      @payload.inspect()
    ].filter( (s) -> s.length).join(' ')


  log: ->
    args = [this]
    args.push arg for arg in arguments
    @transmission.log args...
    return this


  @create = (prevMessage, transform) ->
    new this(prevMessage, transform, null)


  @createSeparate = (prevMessage, payload) ->
    new TargetMessage(prevMessage, null, payload)


  constructor: (@sourceMessage, @transform, @payload) ->
    {@transmission, @pass} = @sourceMessage


  createNextConnectionMessage: (channelNode) ->
    @transmission.ConnectionMessage.createNext(this, channelNode)


  sendToNodeTarget: (line, nodeTarget) ->
    @transmission.JointMessage
      .getOrCreate(this, {nodeTarget})
      .joinMessageFrom(this, line)
    return this


  getPriority: ->
    @getPayload().fixedPriority ? @sourceMessage.getPriority()


  getPayload: -> @payload
