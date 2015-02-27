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
    @targets.forEach (target) -> target.send(message)
    return this
