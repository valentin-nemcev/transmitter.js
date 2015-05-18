'use strict'


ChannelNode = require './channel_node'


module.exports = class VariableChannel extends ChannelNode

  get: -> @channel

  setValue: (newChannel) ->
    oldChannel = @channel
    @channel = newChannel

    # oldChannel?.disconnect(@message)
    @connect(newChannel)
    this
