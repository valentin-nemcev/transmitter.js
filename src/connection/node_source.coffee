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
    message = connectionMessage.getCommunicationFor('message', this)
    @targets.resendCommunication(message, channelNode) if message?
    return this


  receiveMessage: (message) ->
    @targets.sendCommunication(message)
    return this
