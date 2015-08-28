'use strict'

SimpleChannel = require './simple_channel'
PlaceholderNodeLine = require '../connection/placeholder_node_line'

class PlaceholderChannel

  inspect: -> '[' + @constructor.name + ']'

  [
    'inForwardDirection'
    'inBackwardDirection'
    'inDirection'
    'getDirection'
  ].forEach (method) => this::[method] = SimpleChannel::[method]

  connect: -> this
  disconnect: -> this

  toTarget: (@target) -> this

  getConnection: ->
    @connection ?= new PlaceholderNodeLine(
      @target.getNodeTarget(), @getDirection())



module.exports = PlaceholderChannel
