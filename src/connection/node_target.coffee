'use strict'


module.exports = class NodeTarget

  @extend = (nodeClass) ->
    nodeClass::getNodeTarget = ->
      @nodeTarget ?= new NodeTarget(this)


  constructor: (@node) ->
    @sources = new Set()


  connectSource: (source) ->
    @sources.add(source)
    return this


  receiveMessage: (message) ->
    message.sendToTargetNode(@node)
    return this


  receiveQuery: (query) ->
    @sources.forEach (source) -> source.receiveQuery(query)
    return this
