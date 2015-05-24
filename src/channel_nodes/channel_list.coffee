'use strict'


ChannelNode = require './channel_node'


module.exports = class ChannelList extends ChannelNode

  acceptPayload: (payload) ->
    payload.deliverValueState(this)
    return this


  get: -> @channels ? []

  set: (newChannels) ->
    oldChannels = @channels
    @channels = newChannels

    # oldChannel?.disconnect(@message)
    @connect(newChannel) for newChannel in newChannels
    this
