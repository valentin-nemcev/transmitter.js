'use strict'


ChannelNode = require './channel_node'


module.exports = class ChannelVariable extends ChannelNode

  acceptPayload: (payload) ->
    payload.deliverToVariable(this)
    return this


  get: -> @channel

  set: (newChannel) ->
    oldChannel = @channel

    oldChannel.disconnect(@message) if oldChannel?

    @channel = newChannel
    newChannel.connect(@message) if newChannel?
    this
