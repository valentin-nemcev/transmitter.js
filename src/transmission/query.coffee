'use strict'


module.exports = class Query

  constructor: (@transmission, @createResponsePayload, @direction) ->


  _copy: -> new Query(@transmission, @createResponsePayload)


  _trySendingFromNodeTarget: (node) ->
    @wasSent = no
    node.getNodeTarget?()?.receiveQuery(this)
    return @wasSent


  sendFromTargetNode: (node) ->
    return this if @transmission.hasQueryOrMessageForNode(node)
    @transmission.addQueryToNode(this, node)
    unless @_trySendingFromNodeTarget(node)
      @transmission.enqueueQueryForResponseToNode(this, node)
    return this


  sendToSourceNode: (node) ->
    return this if @transmission.hasQueryOrMessageForNode(node)
    @transmission.addQueryToNode(this, node)
    unless @_copy()._trySendingFromNodeTarget(node)
      @transmission.enqueueQueryForResponseFromNode(this, node)
    return this


  sendToSourceAlongDirection: (source, direction) ->
    if @direction == direction
      @wasSent = yes
      source.receiveQuery(this)
    return this
