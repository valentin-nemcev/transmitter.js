'use strict'


ChannelNode = require './channel_node'
ListPayload = require '../payloads/list'


module.exports = class DynamicChannelVariable extends ChannelNode

  acceptPayload: (payload) ->
    payload.deliverToVariable(this)
    return this


  constructor: (@type, @createChannel) ->


  get: -> @channel

  set: (newNodes) ->
    oldChannel = @channel

    oldChannel.disconnect(@message) if oldChannel?

    @channel = newChannel = @createChannel.call(null)

    @payload = ListPayload.setConst(newNodes)

    switch @type
      when 'sources' then newChannel.fromDynamicSources newNodes
      when 'targets' then newChannel.toDynamicTargets newNodes
      else throw new Error "Unknown DynamicChannelVariable type: #{@type}"

    newChannel.connect(@message) if newChannel?
    this


  getPayload: -> @payload
