'use strict'


directions = require '../directions.coffee'


module.exports = class Query

  inspect: -> "Q #{@direction.inspect()}"


  constructor: (@transmission, @direction, @pathLength = 0) ->
    @direction ?= directions.null


  setDirection: (@direction) -> this


  _copy: ->
    new Query(@transmission, @direction, @pathLength + 1)


  _trySendingFromNodeTarget: (node) ->
    @wasSent = no
    node.getNodeTarget?()?.receiveQuery(this)
    return @wasSent


  sendFromTargetNode: (node) ->
    return this if @transmission.hasMessageForNode(node)
    @transmission.addQueryToNode(this, node)
    @_trySendingFromNodeTarget(node)
    return this


  sendToSourceNode: (node) ->
    return this if @transmission.hasMessageForNode(node)
    @transmission.addQueryToNode(this, node)
    unless @_copy()._trySendingFromNodeTarget(node)
      @transmission.enqueueQueryFromNode(this, node, @pathLength)
    return this


  sendToSourceAlongDirection: (source, direction) ->
    if @direction == direction
      @wasSent = yes
      source.receiveQuery(this)
    return this
