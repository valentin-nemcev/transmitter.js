'use strict'


module.exports = class Query

  constructor: (@transmission, @createResponsePayload) ->


  sendFromNode: (node) ->
    node.getNodeTarget().enquire(this)
    return this


  enquireSourceNode: (node) ->
    @transmission.addQueryTo(this, node)
    return this
