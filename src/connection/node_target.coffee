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


  receiveMessage: (message) ->
    message.sendToNode(@node)
    return this


  receiveConnectionMessage: (connectionMessage, channelNode) ->
    query = connectionMessage.getCommunicationFor('query', this)
    if query?
      @sources.resendCommunication(query, channelNode)

    message = connectionMessage.getSelectedMessage(this)
    message.joinConnectionMessage(channelNode)

    return this


  receiveQuery: (query) ->
    @sources.sendCommunication(query)
    return this


  getChannelNodesFor: (comm) -> @sources.getChannelNodesFor(comm)
