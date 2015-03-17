'use strict'


module.exports = class NodeTarget

  @extend = (nodeClass) ->
    nodeClass::getNodeTarget = ->
      @nodeTarget ?= new NodeTarget(this)


  constructor: (@node) ->


  bindSource: (@source) ->
    return this


  receive: (message) ->
    message.sendToNode(@node)
    return this


  enquire: (query) ->
    @source.enquire(query)
    return this
