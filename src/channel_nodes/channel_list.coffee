'use strict'


ChannelNode = require './channel_node'


module.exports = class ChannelList extends ChannelNode

  get: -> @channels ? []

  set: (newChannels) ->
    oldChannels = @channels
    @channels = newChannels

    # oldChannel?.disconnect(@message)
    @connect(newChannel) for newChannel in newChannels
    this
