'use strict'


module.exports = class NodeConnectionLine

  inspect: -> (@source?.inspect() ? null) + '-'


  constructor: (@source, @direction) ->


  setTarget: (@target) -> this


  connect: (message) ->
    @source?.connectTarget(message, this)
    return this


  disconnect: ->
    @source?.disconnectTarget(message, this)
    return this


  receiveQuery: (query) ->
    query.sendToNodeSource(@source) if @source?
    return this


  receiveMessage: (message) ->
    if message.directionMatches(@direction)
      @target.receiveMessage(message)
    return this
