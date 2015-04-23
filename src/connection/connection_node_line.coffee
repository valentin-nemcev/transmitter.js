'use strict'


directions = require '../directions'


module.exports = class ConnectionNodeLine

  inspect: -> '-' + (@target?.inspect() ? null)


  constructor: (@target, @direction = directions.null) ->


  setSource: (@source) -> this


  isConst: -> not @origin?


  setOrigin: (@origin) -> this


  connect: ->
    @target?.connectSource(this)
    return this


  receiveConnectionMessage: (message) ->
    message.deliverToLine(this)
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
    @target?.receiveMessage(message)
    return this
