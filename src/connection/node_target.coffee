'use strict'


MultiMap = require 'collections/multi-map'
FastSet = require 'collections/fast-set'


module.exports = class NodeTarget

  @extend = (nodeClass) ->
    nodeClass::getNodeTarget = -> @nodeTarget ?= new NodeTarget(this)


  inspect: -> '>' + @node.inspect()


  constructor: (@node) ->
    @sources = new MultiMap(null, -> new FastSet())


  connectSource: (origin, source) ->
    @sources.get(origin).add(source)
    return this


  disconnectSource: (origin, source) ->
    originSources = @sources.get(origin)
    originSources.delete(source)
    @sources.delete(originSources) if originSources.length is 0
    return this


  receiveMessage: (message) ->
    message.sendMergedToNode(this, @sources.keys(), @node)
    return this


  receiveQuery: (query) ->
    @sources.forEach (originSources) ->
      originSources.forEach (source) ->
        query.sendToLine(source)
    return this
