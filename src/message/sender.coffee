'use strict'


Message = require '../message'


module.exports = class MessageSender

  @extend = (nodeClass) ->
    Object.assign nodeClass.prototype,
      getMessageSender: ->
        @messageSender ?= new MessageSender()

      sendValue: (value) ->
        @getMessageSender().send(Message.createValue(value))
        return this

      sendBare: ->
        @getMessageSender().send(Message.createBare())
        return this


  constructor: ->
    @targets = new Set()


  bindTarget: (target) ->
    @targets.add(target)
    return this


  send: (message) ->
    @targets.forEach (target) -> target.send(message)
    return this


