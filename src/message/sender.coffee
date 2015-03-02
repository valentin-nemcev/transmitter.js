'use strict'


module.exports = class MessageSender

  @extend = (nodeClass) ->
    Object.assign nodeClass.prototype,
      getMessageSender: ->
        @messageSender ?= new MessageSender()


  constructor: ->
    @targets = new Set()


  bindTarget: (target) ->
    @targets.add(target)
    return this


  send: (message) ->
    message.markAsSentFrom(this)
    @targets.forEach (target) -> target.send(message)
    return this


  enquire: (messageChain) ->
    messageChain.addToQueryQueue(this)
    return this
