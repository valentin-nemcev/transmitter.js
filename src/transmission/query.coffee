'use strict'


module.exports = class Query

  constructor: ({@transmission}) ->


  enquireTargetNode: (node) ->
    node.getNodeTarget().enquire(this)
    return this


  enquireSourceNode: (node) ->
    @transmission.addQueryTo(node)
    return this
