'use strict'


module.exports = class MessageReceiver

  @extend = (nodeClass) ->
    nodeClass::getMessageReceiver = ->
      @messageReceiver ?= new MessageReceiver(this)


  constructor: (@node) ->


  bindSource: (@source) ->
    return this


  send: (message) ->
    message.sendToNode(@node)
    return this


  enquire: (query) ->
    @source.enquire(query)
    return this
