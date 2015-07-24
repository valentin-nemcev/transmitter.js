'use strict'


FastSet = require 'collections/fast-set'
Precedence = require './precedence'


module.exports = class ConnectionMessage

  inspect: ->
    [
      'CM'
      @channelNode?.inspect()
    ].join(' ')


  log: ->
    @transmission.log this, arguments...
    return this


  @createInitial = (transmission) ->
    new this(transmission, null)


  @createNext = (prevMessage, channelNode) ->
    new this(prevMessage.transmission, channelNode)


  constructor: (@transmission, @channelNode, opts = {}) ->
    @points = new FastSet()


  getChannelNode: -> @channelNode


  addPoint: (point) ->
    @points.add(point)
    return this


  updatePoints: ->
    @points.forEach (point) =>
      @log point
      if (comm = @transmission.getCommunicationFor(point))?
        comm.resendFromNodePoint(point, @channelNode)

      if (cachedForMerge = @transmission.getCachedMessage(point))?
        cachedForMerge.resendToNodePoint(point)

    return this
