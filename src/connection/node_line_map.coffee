'use strict'


MultiMap = require 'collections/multi-map'
FastSet = require 'collections/fast-set'


module.exports = class NodeLineMap

  constructor: (@nodePoint) ->
    @lines = new MultiMap(null, -> new FastSet())


  getChannelNodes: ->
    @lines.keys()


  connect: (message, line) ->
    channelNode = message.getChannelNode()
    message.addPoint(@nodePoint)
    @lines.get(channelNode).add(line)
    return this


  disconnect: (message, line) ->
    channelNode = message.getChannelNode()
    message.addPoint(@nodePoint)
    lines = @lines.get(channelNode)
    lines.delete(line)
    @lines.delete(channelNode) if lines.length is 0
    return this


  resendCommunication: (comm, channelNode) ->
    @lines.get(channelNode).forEach (line) ->
      comm.sendToLine(line)
    return this


  sendCommunication: (comm) ->
    @lines.forEach (lines, channelNode) ->
      if comm.tryQueryChannelNode(channelNode)
        lines.forEach (line) -> comm.sendToLine(line)
    return this
