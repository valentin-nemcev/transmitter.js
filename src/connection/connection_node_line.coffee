'use strict'


directions = require '../directions.coffee'


module.exports = class ConnectionNodeLine

  constructor: (@target, @direction = directions.null) ->


  setSource: (@source) -> this


  isConst: -> not @origin?


  setOrigin: (@origin) -> this


  connect: ->
    @target.connectSource(this)
    return this


  receiveConnectionMessage: (message) ->
    message.deliverToLine(this)
    return this


  receiveQuery: (query) ->
    query.sendToSourceAlongDirection(@source, @direction)
    return this


  receiveMessage: (message) ->
    @target.receiveMessage(message)
    return this
