'use strict'


module.exports = class NodeTarget

  @extend = (nodeClass) ->
    nodeClass::getNodeTarget = ->
      @nodeTarget ?= new NodeTarget(this)


  constructor: (@node) ->
    @sources = new Set()


  bindSource: (source) ->
    @sources.add(source)
    return this


  receiveMessage: (message) ->
    message.sendToTargetNode(@node)
    return this


  receiveQuery: (query) ->
    if @sources.size
      @sources.forEach (source) -> source.receiveQuery(query)
    else
      query.sendToResponderNode(@node)
    return this
