'use strict'


module.exports = class MessageSender

  @extend = (nodeClass) ->
    Object.assign nodeClass.prototype,
      getMessageSender: ->
        @messageSender ?= new MessageSender(this)


  constructor: (@node) ->
    @targets = new Set()


  bindTarget: (target) ->
    @targets.add(target)
    return this


  sendMessage: (message) ->
    @targets.forEach (target) -> target.send(message)
    return this


  enquire: (query) ->
    query.enquireSourceNode(@node)
    return this
