'use strict'


ChannelNode = require './channel_node'


module.exports = class ChannelList extends ChannelNode

  constructor: ->
    @channels = []


  acceptPayload: (payload) ->
    payload.deliverToList(this)
    return this


  get: -> @channels.slice()

  set: (newChannels) ->
    oldChannels = @channels

    @disconnect(oldChannel) for oldChannel in oldChannels

    @channels.length = 0
    @channels.push newChannels...
    @connect(newChannel) for newChannel in newChannels
    this
