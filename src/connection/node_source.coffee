'use strict'


MultiMap = require 'collections/multi-map'
FastSet = require 'collections/fast-set'


module.exports = class NodeSource

  @extend = (nodeClass) ->
    nodeClass::getNodeSource = -> @nodeSource ?= new NodeSource(this)


  inspect: -> @node.inspect() + '<'


  constructor: (@node) ->
    @targets = new MultiMap(null, -> new FastSet())


  connectTarget: (origin, target) ->
    @targets.get(origin).add(target)
    return this


  disconnectTarget: (origin, target) ->
    originTargets = @targets.get(origin)
    originTargets.delete(target)
    @targets.delete(originTargets) if originTargets.length is 0
    return this


  receiveMessage: (message) ->
    @targets.forEach (originTargets) ->
      originTargets.forEach (target) ->
        message.sendToLine(target)
    return this


  receiveQuery: (query) ->
    query.sendToNode(@node)
    return this
