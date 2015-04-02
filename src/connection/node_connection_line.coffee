'use strict'


directions = require '../directions.coffee'


module.exports = class NodeConnectionLine

  constructor: (@source, @direction = directions.null) ->


  connectTarget: (@target) ->
    @source.connectTarget(this)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    @target.receiveMessage(message)
    return this
