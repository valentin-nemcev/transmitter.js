'use strict'


FastSet = require 'collections/fast-set'


module.exports = class ConnectionMessage

  inspect: ->
    [
      'CM'
      # 'P:' + @precedence
      @channelNode?.inspect()
    ].join(' ')


  log: ->
    @transmission.log this, arguments...
    return this


  @createInitial = (transmission) ->
    new this(transmission, null, {
      # precedence: 0
    })


  @createNext = (prevMessage, channelNode) ->
    new this(prevMessage.transmission, channelNode, {
      # precedence: prevMessage.precedence
    })


  constructor: (@transmission, @channelNode, opts = {}) ->
    # TODO
    {@precedence} = opts
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


  communicationTypeOrder: 2


  getPrecedence: ->
    [@precedence, @communicationTypeOrder]
