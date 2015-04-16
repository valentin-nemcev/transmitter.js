'use strict'


module.exports = class NodeSource

  @extend = (nodeClass) ->
    Object.assign nodeClass.prototype,
      getNodeSource: ->
        @nodeSource ?= new NodeSource(this)


  constructor: (@node) ->
    @targets = new Set()


  connectTarget: (target) ->
    @targets.add(target)
    return this


  receiveConnectionMessageFrom: (message, line) ->
    message.passMessage(@node, line)
    return this


  receiveMessage: (message) ->
    @targets.forEach (target) ->
      message.sendToLine(target)
    return this


  receiveQuery: (query) ->
    query.sendToSourceNode(@node)
    return this
