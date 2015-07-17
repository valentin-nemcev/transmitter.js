'use strict'


FastSet = require 'collections/fast-set'


module.exports = class NodeTarget

  @extend = (nodeClass) ->
    nodeClass::getNodeTarget = -> @nodeTarget ?= new NodeTarget(this)


  inspect: -> '>' + @node.inspect()


  constructor: (@node) ->
    @sources = new FastSet()


  connectSource: (source) ->
    @sources.add(source)
    return this


  disconnectSource: (source) ->
    @sources.delete(source)
    return this


  receiveMessage: (message) ->
    message.sendToNode(@node)
    return this


  receiveQuery: (query) ->
    @sources.forEach (source) ->
      query.sendToLine(source)
    return this
