'use strict'


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


  receiveConnectionMessage: (message) ->
    for channel in @getChannels()
      channel.receiveConnectionMessage(message)
    return this


  connect: (tr) ->
    for channel in @getChannels()
      channel.connect(tr)
    return this
