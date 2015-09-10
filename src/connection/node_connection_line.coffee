'use strict'


module.exports = class NodeConnectionLine

  inspect: -> (@source?.inspect() ? null) + @direction.inspect()


  constructor: (@source, @direction) ->


  setTarget: (@target) -> this


  connect: (message) ->
    @source?.connectLine(message, this)
    return this


  disconnect: (message) ->
    @source?.disconnectLine(message, this)
    return this


  acceptsCommunication: (message) ->
    message.directionMatches(@direction)


  receiveMessage: (message) ->
    @target.receiveMessage(message)
    return this


  receiveQuery: (query) ->
    query.sendToNodeSource(this, @source) if @source?
    return this
