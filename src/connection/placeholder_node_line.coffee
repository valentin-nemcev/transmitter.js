'use strict'


module.exports = class PlaceholderNodeLine

  inspect: -> '.' + @direction.inspect() + @target.inspect()


  constructor: (@target, @direction) ->


  connect: (message) ->
    @target.connectSource(message, this)
    return this


  disconnect: (message) ->
    @target.disconnectSource(message, this)
    return this


  acceptsCommunication: (query) ->
    query.directionMatches(@direction)


  receiveQuery: (query) ->
    # if @acceptsCommunication(query)
    #   query.addPassedLine(this)
    #   query.createNextQuery().enqueueForSourceNode(this)
    return this
