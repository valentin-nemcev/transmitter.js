'use strict'


ChannelNode = require './channel_node'


module.exports = class ListChannel extends ChannelNode

  get: -> @channels ? []

  setValue: (newChannels) ->
    oldChannels = @channels
    @channels = newChannels

    # oldChannel?.disconnect(@message)
    @connect(newChannel) for newChannel in newChannels
    this
