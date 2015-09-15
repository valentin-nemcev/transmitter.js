'use strict'


module.exports = class NodePointTransmissionHub

  constructor: (@comm, @nodePoint) ->
    @updatedChannelNodes = new Set()
    {@transmission, @pass} = @comm


  sendForAll: ->
    @nodePoint.getChannelNodesFor(@comm).forEach (channelNode) =>
      if @_tryQueryChannelNode(channelNode)
        @sendForChannelNode(channelNode)
    return this


  sendForChannelNode: (channelNode) ->
    unless @updatedChannelNodes.has(channelNode)
      @updatedChannelNodes.add(channelNode)
      @nodePoint.receiveCommunicationForChannelNode(@comm, channelNode)
    return this


  areAllChannelNodesUpdated: ->
    for node in @nodePoint.getChannelNodesFor(@comm)
      return false unless @_channelNodeUpdated(node)
    return true


  _tryQueryChannelNode: (channelNode) ->
    if not @_channelNodeUpdated(channelNode)
      @transmission.Query.createNextConnection(@comm)
        .sendToChannelNode(channelNode)
      false
    else
      true


  _channelNodeUpdated: (channelNode) ->
    channelNode is null \
      or @transmission.getCommunicationFor(@pass, channelNode)
