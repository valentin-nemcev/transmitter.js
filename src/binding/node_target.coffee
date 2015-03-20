'use strict'


module.exports = class NodeTarget

  @extend = (nodeClass) ->
    nodeClass::getNodeTarget = ->
      @nodeTarget ?= new NodeTarget(this)


  constructor: (@node) ->


  bindSource: (@source) ->
    return this


  receiveMessage: (message) ->
    message.sendToTargetNode(@node)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
