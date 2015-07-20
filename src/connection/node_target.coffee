'use strict'


MultiMap = require 'collections/multi-map'
FastSet = require 'collections/fast-set'


module.exports = class NodeTarget

  @extend = (nodeClass) ->
    nodeClass::getNodeTarget = -> @nodeTarget ?= new NodeTarget(this)


  inspect: -> '>' + @node.inspect()


  constructor: (@node) ->
    @sources = new MultiMap(null, -> new FastSet())


  connectSource: (message, source) ->
    origin = message.getOrigin()
    message.addPoint(this)
    @sources.get(origin).add(source)
    return this


  disconnectSource: (message, source) ->
    origin = message.getOrigin()
    message.addPoint(this)
    originSources = @sources.get(origin)
    originSources.delete(source)
    @sources.delete(origin) if originSources.length is 0
    return this


  receiveMessage: (message) ->
    message.sendMergedToNode(this, @sources.keys(), @node)
    return this


  passCommunication: (query, origin) ->
    @sources.get(origin).forEach (source) -> query.sendToLine(source)
    return this


  receiveQuery: (query) ->
    @sources.forEach (sources, origin) ->
      if not origin? or query.tryQueryOrigin(origin)
        sources.forEach (source) -> query.sendToLine(source)
    return this
