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


  communicationType: 'query'


  resendQuery: (query, channelNode) ->
    @sources.resendCommunication(query, channelNode)
    return this


  receiveQuery: (query) ->
    @sources.sendCommunication(query)
    return this


  getChannelNodesFor: (comm) -> @sources.getChannelNodesFor(comm)
