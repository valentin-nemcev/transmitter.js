'use strict'


{inspect} = require 'util'

MultiMap = require 'collections/multi-map'
Set = require 'collections/set'


class LineSet extends Set

  acceptsCommunication: (comm) ->
    @some (line) -> line.acceptsCommunication(comm)

  receiveCommunication: (comm) ->
    @forEach (line) ->
      comm.sendToLine(line) if line.acceptsCommunication(comm)



module.exports = class NodeLineMap

  constructor: (@node) ->
    @channelNodeToLines = new MultiMap(null, -> new LineSet())


  getChannelNodesFor: (comm) ->
    channelNode for [channelNode, lines] in @channelNodeToLines.entries() \
      when lines.acceptsCommunication(comm)


  connectLine: (message, line) ->
    channelNode = message.getSourceChannelNode()
    message.addTargetPoint(this)
    @channelNodeToLines.get(channelNode).add(line)
    return this


  disconnectLine: (message, line) ->
    channelNode = message.getSourceChannelNode()
    message.removeTargetPoint(this)
    lines = @channelNodeToLines.get(channelNode)
    lines.delete(line)
    @channelNodeToLines.delete(channelNode) if lines.length is 0
    return this


  receiveCommunicationForChannelNode: (comm, channelNode) ->
    lines = @channelNodeToLines.get(channelNode)
    lines.receiveCommunication(comm)
    return this
