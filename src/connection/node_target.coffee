'use strict'


NodePoint = require './node_point'


module.exports = class NodeTarget extends NodePoint

  inspect: -> '>' + @node.inspect()


  receiveConnectionMessage: (connectionMessage, channelNode) ->
    connectionMessage.getJointMessage(@node)
      .joinTargetConnectionMessage(channelNode)
    return this
