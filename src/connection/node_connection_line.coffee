'use strict'


module.exports = class NodeConnectionLine

  inspect: -> (@source?.inspect() ? null) + '-'


  constructor: (@source, @direction) ->


  setTarget: (@target) -> this


  isConst: -> not @origin?


  setOrigin: (@origin) -> this


  connect: ->
    @source?.connectTarget(this)
    return this


  receiveConnectionMessage: (message) ->
    message.sendToLine(this)
    message.passCommunication(@source, this) if @source?
    return this


  receiveConnectionQuery: (query) ->
    @origin.receiveQuery(query)
    return this


  receiveQuery: (query) ->
    query.sendToNodeSource(@source) if @source?
    return this


  receiveOutgoingQuery: ->
    return this


  receiveOutgoingMessage: (message) ->
    if message.directionMatches(@direction)
      @target.receiveMessage(message)
    return this
