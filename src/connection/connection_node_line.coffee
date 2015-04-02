'use strict'


directions = require '../directions.coffee'


module.exports = class ConnectionNodeLine

  constructor: (@target, @direction = directions.null) ->


  connectSource: (@source) ->
    @target.connectSource(this)


  receiveQuery: (query) ->
    query.sendToSourceAlongDirection(@source, @direction)
    return this


  receiveMessage: (message) ->
    @target.receiveMessage(message)
    return this
