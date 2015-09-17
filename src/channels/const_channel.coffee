'use strict'


SimpleChannel = require './simple_channel'
ConstNodeLine = require '../connection/const_node_line'


module.exports = class ConstChannel

  inspect: -> '[' + @constructor.name + ']'

  [
    'assertPresent'
    'inForwardDirection'
    'inBackwardDirection'
    'inDirection'
    'getDirection'
    'connect'
    'disconnect'
    'init'
  ].forEach (method) => this::[method] = SimpleChannel::[method]


  toTarget: (@target) ->
    @assertPresent('Target', @target)
    return this


  withPayload: (@createPayload) -> this


  getConnection: ->
    @connection ?= new ConstNodeLine(
      @target.getNodeTarget(), @getDirection(), @createPayload)
