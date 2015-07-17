'use strict'


ChannelNode = require './channel_node'


module.exports = class ChannelVariable extends ChannelNode

  acceptPayload: (payload) ->
    payload.deliverToVariable(this)
    return this


  get: -> @channel

  set: (newChannel) ->
    oldChannel = @channel

    @disconnect(oldChannel) if oldChannel?

    @channel = newChannel
    @connect(newChannel) if newChannel?
    this
