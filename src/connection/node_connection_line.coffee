'use strict'


directions = require '../directions.coffee'


module.exports = class NodeConnectionLine

  constructor: (@source, @direction = directions.null) ->


  setTarget: (@target) -> this


  isConst: -> not @origin?


  setOrigin: (@origin) -> this


  connect: ->
    @source.connectTarget(this)
    return this


  receiveConnectionMessage: (message) ->
    message.deliverToLine(this)
    @source.receiveConnectionMessageFrom(message, this)
    return this


  receiveConnectionQuery: (query) ->
    query.setDirection(@direction)
    @origin.receiveQuery(query)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    @target.receiveMessage(message)
    return this
