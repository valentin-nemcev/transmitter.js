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
    @target?.receiveConnectionMessageFrom(message, this)
    return this


  receiveConnectionQuery: (query) ->
    query.setDirection(@direction)
    @origin.receiveQuery(query)
    return this


  receiveQuery: (query) ->
    query.sendToSourceAlongDirection(@source, @direction)
    return this


  receiveMessage: (message) ->
    message.sendToNodeTarget(@target) if @target?
    return this
