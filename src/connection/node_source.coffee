'use strict'


MultiMap = require 'collections/multi-map'
FastSet = require 'collections/fast-set'


module.exports = class NodeSource

  @extend = (nodeClass) ->
    nodeClass::getNodeSource = -> @nodeSource ?= new NodeSource(this)


  inspect: -> @node.inspect() + '<'


  constructor: (@node) ->
    @targets = new MultiMap(null, -> new FastSet())


  connectTarget: (message, target) ->
    origin = message.getOrigin()
    message.addPoint(this)
    @targets.get(origin).add(target)
    return this


  disconnectTarget: (message, target) ->
    origin = message.getOrigin()
    message.addPoint(this)
    originTargets = @targets.get(origin)
    originTargets.delete(target)
    @targets.delete(originTargets) if originTargets.length is 0
    return this


  passCommunication: (message, origin) ->
    @targets.get(origin).forEach (target) ->
      message.sendToLine(target)
    return this


  receiveMessage: (message) ->
    @targets.forEach (targets, origin) ->
      if not origin? or message.tryQueryOrigin(origin)
        targets.forEach (target) -> message.sendToLine(target)
    return this


  receiveQuery: (query) ->
    query.sendToNode(@node)
    return this
