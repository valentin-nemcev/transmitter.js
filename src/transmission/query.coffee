'use strict'


module.exports = class Query

  constructor: (@transmission, @createResponsePayload) ->


  sendFromTargetNode: (node) ->
    node.getNodeTarget().receiveQuery(this)
    return this


  sendToSourceNode: (node) ->
    @transmission.addQueryTo(this, node)
    return this
