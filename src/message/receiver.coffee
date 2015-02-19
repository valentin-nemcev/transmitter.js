'use strict'


module.exports = class MessageReceiver

  @extend = (nodeClass) ->
    nodeClass::getMessageReceiver = ->
      @messageReceiver ?= new MessageReceiver(this)


  constructor: (@node) ->


  send: (message) ->
    message.deliver(@node)
    return this
