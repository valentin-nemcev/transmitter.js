'use strict'


BidirectionalChannel = require './bidirectional_channel'
CompositeChannel = require './composite_channel'


CompositeChannel::defineVariableChannel = ->
  channel = new VariableChannel()
  @addChannel(channel)
  return channel


module.exports = class VariableChannel extends BidirectionalChannel
