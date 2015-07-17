'use strict'


FastSet = require 'collections/fast-set'


module.exports = class NodeSource

  @extend = (nodeClass) ->
    nodeClass::getNodeSource = -> @nodeSource ?= new NodeSource(this)


  inspect: -> @node.inspect() + '<'


  constructor: (@node) ->
    @targets = new FastSet()


  connectTarget: (target) ->
    @targets.add(target)
    return this


  disconnectTarget: (target) ->
    @targets.delete(target)
    return this


  receiveMessage: (message) ->
    @targets.forEach (target) ->
      message.sendToLine(target)
    return this


  receiveQuery: (query) ->
    query.sendToNode(@node)
    return this
