'use strict'


NodePoint = require './node_point'


module.exports = class NodeSource extends NodePoint

  inspect: -> @node.inspect() + '<'


  getPlaceholderPayload: ->
    @node.createPlaceholderPayload()


  receiveConnectionMessage: (connectionMessage, channelNode) ->
    connectionMessage.getJointMessage(@node)
      .joinSourceConnectionMessage(channelNode)
    return this
