'use strict'


NodeLineMap = require './node_line_map'


module.exports = class NodeTarget

  inspect: -> '>' + @node.inspect()


  constructor: (@node) ->
    @sources = new NodeLineMap(this)


  connectSource: (message, source) -> 
    @sources.connect(message, source)
    return this


  disconnectSource: (message, source) ->
    @sources.disconnect(message, source)
    return this


  receiveConnectionMessage: (connectionMessage, channelNode) ->
    connectionMessage.getSelectedMessage(@node)
      .joinTargetConnectionMessage(channelNode)
    return this


  receiveQueryForChannelNode: (query, channelNode) ->
    @sources.resendCommunication(query, channelNode)
    return this


  getChannelNodesFor: (comm) -> @sources.getChannelNodesFor(comm)
