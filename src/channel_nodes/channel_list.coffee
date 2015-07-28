'use strict'


ChannelNode = require './channel_node'


module.exports = class ChannelList extends ChannelNode

  constructor: ->
    @channels = []


  acceptPayload: (payload) ->
    payload.deliverToList(this)
    return this


  set: (newChannels) ->
    oldChannels = @channels

    oldChannel.disconnect(@message) for oldChannel in oldChannels

    @channels.length = 0
    @channels.push newChannels...
    newChannel.connect(@message) for newChannel in newChannels
    this


  addAt: (el, pos) ->
    pos ?= @channels.length
    if pos == @channels.length
      @channels.push el
    else
      @channels.splice(pos, 0, el)

    el.connect(@message)
    return this


  removeAt: (pos) ->
    el = @channels.splice(pos, 1)[0]
    el.disconnect(@message)
    return this


  move: (fromPos, toPos) ->
    @channels.splice(toPos, 0, @channels.splice(fromPos, 1)[0])
    return this


  get: ->
    @channels.slice()


  getAt: (pos) ->
    @channels[pos]


  getSize: ->
    @channels.length
