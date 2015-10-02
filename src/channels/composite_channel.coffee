'use strict'


SimpleChannel = require './simple_channel'
Record = require '../nodes/record'


module.exports = class CompositeChannel

  inspect: -> '[' + @constructor.name + ']'


  @defineLazy = Record.defineLazy


  @defineChannel = (createChannel) ->
    (@::classChannelCreateFunctions ?= []).push createChannel
    return this


  defineChannel: (createChannel) ->
    (@instanceChannelCreateFunctions ?= []).push createChannel
    return this


  addChannel: (channel) ->
    (@instanceChannels ?= []).push channel
    return this


  createChannels: ->
    (@classChannelCreateFunctions ? [])
      .concat(@instanceChannelCreateFunctions ? [])
      .map (createChannel) => createChannel.call(this)
      .concat(@instanceChannels ? [])


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
