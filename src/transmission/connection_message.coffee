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
    args = [this]
    args.push arg for arg in arguments
    @transmission.log args...
    return this


  @createInitial = (transmission) ->
    new this(transmission, Pass.createQueryDefault(), null)


  @createNext = (prevMessage, sourceChannelNode) ->
    new this(prevMessage.transmission, prevMessage.pass, sourceChannelNode)


  constructor: (@transmission, @pass, @sourceChannelNode) ->
    @targetPointsToUpdate =
      new FastSet().addEach(@sourceChannelNode?.getTargetPoints())


  createPlaceholderConnectionMessage: (sourceChannelNode) ->
    ConnectionMessage.createNext(this, sourceChannelNode)


  createNextQuery: ->
    @transmission.Query.createNext(this)


  getSourceChannelNode: -> @sourceChannelNode


  addTargetPoint: (targetPoint) ->
    @targetPointsToUpdate.add(targetPoint)
    @sourceChannelNode?.addTargetPoint(targetPoint)
    return this


  removeTargetPoint: (targetPoint) ->
    @targetPointsToUpdate.add(targetPoint)
    @sourceChannelNode?.removeTargetPoint(targetPoint)
    return this


  getJointMessage: (node) ->
    @transmission.JointMessage.getOrCreate(this, {node})


  sendToTargetPoints: ->
    @targetPointsToUpdate.forEach (targetPoint) =>
      @log targetPoint
      targetPoint.receiveConnectionMessage(this, @sourceChannelNode)
      # @log targetPoint, 'complete'
    return this
