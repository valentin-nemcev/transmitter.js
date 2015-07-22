'use strict'


MultiMap = require 'collections/multi-map'
FastSet = require 'collections/fast-set'


module.exports = class NodeLineMap

  constructor: (@nodePoint) ->
    @channelNodeToLines = new MultiMap(null, -> new FastSet())


  getChannelNodes: ->
    @channelNodeToLines.keys()


  connect: (message, line) ->
    channelNode = message.getChannelNode()
    message.addPoint(@nodePoint)
    @channelNodeToLines.get(channelNode).add(line)
    return this


  disconnect: (message, line) ->
    channelNode = message.getChannelNode()
    message.addPoint(@nodePoint)
    lines = @channelNodeToLines.get(channelNode)
    lines.delete(line)
    @channelNodeToLines.delete(channelNode) if lines.length is 0
    return this


  resendCommunication: (comm, channelNode) ->
    @channelNodeToLines.get(channelNode).forEach (line) ->
      comm.sendToLine(line)
    return this


  sendCommunication: (comm) ->
    @channelNodeToLines.forEach (lines, channelNode) ->
      if comm.tryQueryChannelNode(channelNode)
        lines.forEach (line) -> comm.sendToLine(line)
    return this
