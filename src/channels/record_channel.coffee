'use strict'


BidirectionalChannel = require './bidirectional_channel'


module.exports = class RecordChannel

  @defineChannel = (createChannel) ->
    (@::channelCreateFunctions ?= []).push createChannel
    return this


  createChannels: ->
    for createChannel in @channelCreateFunctions
      createChannel.call(this, new BidirectionalChannel())


  getChannels: -> @channels ?= @createChannels()


  receiveConnectionMessage: (message) ->
    for channel in @getChannels()
      channel.receiveConnectionMessage(message)
    return this


  connect: (tr) ->
    for channel in @getChannels()
      channel.connect(tr)
    return this
