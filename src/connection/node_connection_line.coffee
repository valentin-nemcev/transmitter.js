'use strict'


module.exports = class NodeConnectionLine

  inspect: -> (@source?.inspect() ? null) + @direction.inspect()


  constructor: (@source, @direction) ->


  setTarget: (@target) -> this


  connect: (message) ->
    @source?.connectTarget(message, this)
    return this


  disconnect: (message) ->
    @source?.disconnectTarget(message, this)
    return this


  acceptsCommunication: (message) ->
    message.directionMatches(@direction)


  receiveMessage: (message) ->
    if @acceptsCommunication(message)
      @target.receiveMessage(message)
    return this


  receiveQuery: (query) ->
    query.sendToNodeSource(@source) if @source?
    return this
