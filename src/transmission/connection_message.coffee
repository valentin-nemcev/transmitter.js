'use strict'


{inspect} = require 'util'

FastSet = require 'collections/fast-set'

Pass = require './pass'


module.exports = class ConnectionMessage

  inspect: ->
    [
      'CM'
      inspect @pass
      inspect @sourceChannelNode
    ].join(' ')


  log: (arg) ->
    @transmission.log this, arg
    return this


  @createInitial = (transmission) ->
    new this(transmission, null,
      pass: Pass.createQueryDefault(),
    )


  @createNext = (prevMessage, sourceChannelNode) ->
    new this(prevMessage.transmission, sourceChannelNode, {
      pass: prevMessage.pass
    })


  constructor: (@transmission, @sourceChannelNode, opts = {}) ->
    {@pass} = opts
    @targetPointsToUpdate =
      new FastSet().addEach(@sourceChannelNode?.getTargetPoints())


  createPlaceholderConnectionMessage: (sourceChannelNode) ->
    ConnectionMessage.createNext(this, sourceChannelNode)


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
      comm?.resendFromNodePoint(targetPoint, @sourceChannelNode, this)

      if (cachedForMerge = @transmission.getCachedMessage(targetPoint))?
        cachedForMerge.resend()

      # TODO: Refactor
      if targetPoint.communicationType is 'query'
        @transmission.Query.createNext(this)
          .sendFromNodeToNodeTarget(targetPoint.node, targetPoint)

    return this
