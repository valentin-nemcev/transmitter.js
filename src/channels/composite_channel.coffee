'use strict'


SimpleChannel = require './simple_channel'


module.exports = class CompositeChannel

  @defineChannel = (createChannel) ->
    (@::classChannelCreateFunctions ?= []).push createChannel
    return this


  defineChannel: (createChannel) ->
    (@instanceChannelCreateFunctions ?= []).push createChannel
    return this


  createChannels: ->
    (@classChannelCreateFunctions ? [])
      .concat(@instanceChannelCreateFunctions ? [])
      .map (createChannel) => createChannel.call(this)


  getChannels: -> @channels ?= @createChannels()


  connect: (message) ->
    for channel in @getChannels()
      channel.connect(message)
    return this


  disconnect: (message) ->
    for channel in @getChannels()
      channel.disconnect(message)
    return this


  init: SimpleChannel::init
