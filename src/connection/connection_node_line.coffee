'use strict'


module.exports = class ConnectionNodeLine

  inspect: -> '-' + (@target?.inspect() ? null)


  constructor: (@target, @direction) ->


  setSource: (@source) -> this


  isConst: -> not @origin?


  setOrigin: (@origin) -> this


  connect: ->
    @target?.connectSource(this)
    return this


  receiveConnectionMessage: (message) ->
    message.sendToLine(this)
    message.passQuery(@target, this) if @target?
    return this


  receiveConnectionQuery: (query) ->
    @origin.receiveQuery(query)
    return this


  receiveOutgoingMessage: ->
    return this


  receiveOutgoingQuery: (query) ->
    if query.directionMatches(@direction)
      @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    message.sendToNodeTarget(@target) if @target?
    return this
