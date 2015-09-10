'use strict'


module.exports = class PlaceholderNodeLine

  inspect: -> '.' + @direction.inspect() + @target.inspect()


  constructor: (@target, @direction) ->


  connect: (message) ->
    @target.connectLine(message, this)
    return this


  disconnect: (message) ->
    @target.disconnectLine(message, this)
    return this


  acceptsCommunication: (query) ->
    query.directionMatches(@direction)


  receiveQuery: (query) ->
    return this
