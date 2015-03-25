'use strict'


module.exports = class Query

  constructor: (@transmission, @createResponsePayload) ->


  sendFromTargetNode: (node) ->
    node.getNodeTarget().receiveQuery(this)
    return this


  sendToSourceNode: (node) ->
    if node.getNodeTarget?
      @sendFromTargetNode(node)
    else
      @sendToResponderNode(node)
    return this


  sendToResponderNode: (node) ->
    @transmission.addQueryTo(this, node)
    return this
