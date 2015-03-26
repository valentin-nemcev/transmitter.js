'use strict'


module.exports = class Query

  constructor: (@transmission, @createResponsePayload) ->


  sendFromTargetNode: (node) ->
    return this if @transmission.hasQueryOrMessageForNode(node)
    @transmission.addQueryToNode(this, node)
    node.getNodeTarget().receiveQuery(this)
    return this


  sendToSourceNode: (node) ->
    return this if @transmission.hasQueryOrMessageForNode(node)
    @transmission.addQueryToNode(this, node)
    if node.getNodeTarget?
      node.getNodeTarget().receiveQuery(this)
    else
      @sendToResponderNode(node)
    return this


  sendToResponderNode: (node) ->
    @transmission.enqueueQueryForResponseFromNode(this, node)
    return this
