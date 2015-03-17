'use strict'


module.exports = class NodeSource

  @extend = (nodeClass) ->
    Object.assign nodeClass.prototype,
      getMessageSender: ->
        @messageSender ?= new NodeSource(this)


  constructor: (@node) ->
    @targets = new Set()


  bindTarget: (target) ->
    @targets.add(target)
    return this


  sendMessage: (message) ->
    @targets.forEach (target) -> target.receive(message)
    return this


  enquire: (query) ->
    query.enquireSourceNode(@node)
    return this
