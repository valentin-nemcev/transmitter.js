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

  constructor: (@nodePoint) ->
    @channelNodeToLines = new MultiMap(null, -> new LineSet())


  getChannelNodesFor: (comm) ->
    channelNode for [channelNode, lines] in @channelNodeToLines.entries() \
      when lines.acceptsCommunication(comm)


  connect: (message, line) ->
    channelNode = message.getSourceChannelNode()
    message.addTargetPoint(@nodePoint)
    @channelNodeToLines.get(channelNode).add(line)
    return this


  disconnect: (message, line) ->
    channelNode = message.getSourceChannelNode()
    message.removeTargetPoint(@nodePoint)
    lines = @channelNodeToLines.get(channelNode)
    lines.delete(line)
    @channelNodeToLines.delete(channelNode) if lines.length is 0
    return this


  resendCommunication: (comm, channelNode) ->
    lines = @channelNodeToLines.get(channelNode)
    lines.receiveCommunication(comm)
    comm.addPassedChannelNode(channelNode)
    return this


  sendCommunication: (comm) ->
    @channelNodeToLines.forEach (lines, channelNode) =>
      if lines.acceptsCommunication(comm) \
        and comm.tryQueryChannelNode(channelNode)
          lines.receiveCommunication(comm)
          comm.addPassedChannelNode(channelNode)
    return this
