'use strict'


directions = require '../directions'


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


  sendToLine: (line) ->
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveQuery(this)
    else
      line.receiveConnectionQuery(@transmission.getSender().createQuery())
    return this


  sendFromTargetNode: (node) ->
    return this if @transmission.hasMessageFor(node)
    @transmission.addQueryFor(this, node)
    @_trySendingFromNodeTarget(node)
    return this


  sendToSourceNode: (node) ->
    return this if @transmission.hasMessageFor(node)
    @transmission.addQueryFor(this, node)
    unless @_copy()._trySendingFromNodeTarget(node)
      @transmission.enqueueQueryFor(this, node, @pathLength)
    return this


  sendToSourceAlongDirection: (source, direction) ->
    if @direction == direction
      @wasSent = yes
      source.receiveQuery(this)
    return this
