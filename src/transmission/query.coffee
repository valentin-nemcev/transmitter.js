'use strict'


module.exports = class Query

  constructor: ({@messageChain}) ->


  enquireTargetNode: (node) ->
    node.getMessageReceiver().enquire(this)
    return this


  enquireSourceNode: (node) ->
    @messageChain.addQueryTo(node)
    return this
