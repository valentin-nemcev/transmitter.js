'use strict'


{inspect} = require 'util'

FastSet = require 'collections/fast-set'

Pass = require './pass'
Nesting = require './nesting'


module.exports = class ConnectionMessage

  inspect: ->
    [
      'CM'
      inspect @nesting
      inspect @pass
      inspect @sourceChannelNode
    ].join(' ')


  log: (arg) ->
    @transmission.log this, arg
    return this


  @createInitial = (transmission) ->
    new this(transmission, null,
      pass: Pass.createQueryDefault(),
      nesting: Nesting.createInitial()
    )


  @createNext = (prevMessage, sourceChannelNode) ->
    new this(prevMessage.transmission, sourceChannelNode, {
      pass: prevMessage.pass
      nesting: prevMessage.nesting.increase()
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
      comm?.resendFromNodePoint(targetPoint, @sourceChannelNode, this)

      if (cachedForMerge = @transmission.getCachedMessage(targetPoint))?
        cachedForMerge.resend()

      # TODO: Refactor
      if targetPoint.communicationType is 'query'
        @transmission.Query.createNext(this)
          .sendFromNodeToNodeTarget(targetPoint.node, targetPoint)

    return this
