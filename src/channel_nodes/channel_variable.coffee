'use strict'


ChannelNode = require './channel_node'


module.exports = class ChannelVariable extends ChannelNode

  acceptPayload: (payload) ->
    payload.deliverValueState(this)
    return this


  get: -> @channel

  set: (newChannel) ->
    oldChannel = @channel
    @channel = newChannel

    # oldChannel?.disconnect(@message)
    @connect(newChannel)
    this
