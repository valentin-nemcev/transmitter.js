'use strict'


module.exports = class NodeSource

  @extend = (nodeClass) ->
    Object.assign nodeClass.prototype,
      getNodeSource: ->
        @nodeSource ?= new NodeSource(this)


  constructor: (@node) ->
    @targets = new Set()


  connectTarget: (target) ->
    @targets.add(target)
    return this


  receiveMessage: (message) ->
    # @queryForTargets()
    # @getTargets().forEach (target) -> target.receiveMessage(message)
    @targets.forEach (target) -> target.receiveMessage(message)
    return this


  receiveQuery: (query) ->
    query.sendToSourceNode(@node)
    return this
