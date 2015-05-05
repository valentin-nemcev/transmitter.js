'use strict'


directions = require '../directions'


module.exports = class Query

  inspect: -> "Q #{@direction.inspect()}"


  constructor: (@transmission, @direction, @pathLength = 0) ->
    @direction ?= directions.null


  setDirection: (@direction) -> this


  _copy: ->
    new Query(@transmission, @direction, @pathLength + 1)


  sendToLine: (line) ->
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveQuery(this)
    else
      line.receiveConnectionQuery(@transmission.getSender().createQuery())
    return this


  sendToNodeSource: (nodeSource) ->
    return this if @transmission.hasMessageFor(nodeSource)
    @transmission.addQueryFor(this, nodeSource)
    nodeSource.receiveQuery(this)
    return this


  sendToNode: (node) ->
    node.routeQuery(@_copy())
    return this


  completeRouting: (node) ->
    @transmission.enqueueQueryFor(this, node, @pathLength) unless @wasSent
    return this


  sendToNodeTarget: (nodeTarget) ->
    return this if @transmission.hasMessageFor(nodeTarget)
    @transmission.addQueryFor(this, nodeTarget)
    nodeTarget.receiveQuery(this)
    return this


  sendToSourceAlongDirection: (source, direction) ->
    if @direction == direction
      @wasSent = yes
      source.receiveQuery(this)
    return this
