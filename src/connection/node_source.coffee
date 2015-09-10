'use strict'


NodeLineMap = require './node_line_map'


module.exports = class NodeSource

  inspect: -> @node.inspect() + '<'


  constructor: (@node) ->
    @targets = new NodeLineMap(this)


  connectTarget: (message, target) ->
    @targets.connect(message, target)
    return this


  disconnectTarget: (message, target) ->
    @targets.disconnect(message, target)
    return this


  receiveQuery: (query) ->
    query.sendToNode(@node)
    return this


  receiveConnectionMessage: (connectionMessage, channelNode) ->
    connectionMessage.getJointMessage(@node)
      .joinSourceConnectionMessage(channelNode)
    return this


  receiveMessageForChannelNode: (message, channelNode) ->
    @targets.resendCommunication(message, channelNode)
    return this


  getChannelNodesFor: (comm) -> @targets.getChannelNodesFor(comm)
