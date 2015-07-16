'use strict'


Set = require 'collections/set'


module.exports = class NodeTarget

  @extend = (nodeClass) ->
    nodeClass::getNodeTarget = -> @nodeTarget ?= new NodeTarget(this)


  inspect: -> '>' + @node.inspect()


  constructor: (@node) ->
    @sources = new Set()


  connectSource: (source) ->
    @sources.add(source)
    return this


  receiveMessage: (message) ->
    message.sendToNode(@node)
    return this


  receiveQuery: (query) ->
    @sources.forEach (source) ->
      query.sendToLine(source)
    return this
