'use strict'


Set = require 'collections/set'


module.exports = class NodeSource

  @extend = (nodeClass) ->
    nodeClass::getNodeSource = -> @nodeSource ?= new NodeSource(this)


  inspect: -> @node.inspect() + '<'


  constructor: (@node) ->
    @targets = new Set()


  connectTarget: (target) ->
    @targets.add(target)
    return this


  receiveMessage: (message) ->
    @targets.forEach (target) ->
      message.sendToLine(target)
    return this


  receiveQuery: (query) ->
    query.sendToNode(@node)
    return this
