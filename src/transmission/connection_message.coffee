'use strict'


{inspect} = require 'util'

FastSet = require 'collections/fast-set'

Pass = require './pass'


module.exports = class ConnectionMessage

  inspect: ->
    [
      'CM'
      inspect @sourceChannelNode
    ].join(' ')


  log: (arg) ->
    @transmission.log this, arg
    return this


  @createInitial = (transmission) ->
    new this(transmission, null, pass: Pass.createQueryDefault(), nesting: 0)


  @createNext = (prevMessage, sourceChannelNode) ->
    new this(prevMessage.transmission, sourceChannelNode, {
      pass: prevMessage.pass
      nesting: prevMessage.nesting + 1
    })


  constructor: (@transmission, @sourceChannelNode, opts = {}) ->
    {@pass, @nesting} = opts
    @targetPointsToUpdate =
      new FastSet().addEach(@sourceChannelNode?.getTargetPoints())


  getSourceChannelNode: -> @sourceChannelNode


  addTargetPoint: (targetPoint) ->
    @targetPointsToUpdate.add(targetPoint)
    @sourceChannelNode?.addTargetPoint(targetPoint)
    return this


  removeTargetPoint: (targetPoint) ->
    @targetPointsToUpdate.add(targetPoint)
    @sourceChannelNode?.removeTargetPoint(targetPoint)
    return this


  updateTargetPoints: ->
    @targetPointsToUpdate.forEach (targetPoint) =>
      @log targetPoint
      comm = @transmission.getCommunicationFor(
        targetPoint.communicationType, @pass, targetPoint)
      comm?.resendFromNodePoint(targetPoint, @sourceChannelNode)

      if (cachedForMerge = @transmission.getCachedMessage(targetPoint))?
        cachedForMerge.resend()

      if targetPoint.communicationType is 'query'
        @transmission.Query.createNext(this)
          .sendFromNodeToNodeTarget(targetPoint.node, targetPoint)

    return this
