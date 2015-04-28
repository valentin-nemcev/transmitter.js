'use strict'


ChannelBuilder = require '../channel_builder'


module.exports = class RecordChannel

  @defineChannel = (createChannel) ->
    (@::channelCreateFunctions ?= []).push createChannel
    return this


  createChannels: ->
    for createChannel in @channelCreateFunctions
      createChannel.call(this, new ChannelBuilder())


  getChannels: -> @channels ?= @createChannels()


  receiveConnectionMessage: (message) ->
    for channel in @getChannels()
      channel.receiveConnectionMessage(message)
    return this
