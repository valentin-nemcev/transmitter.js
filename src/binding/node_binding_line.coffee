'use strict'


directions = require './directions.coffee'


module.exports = class NodeBindingLine

  constructor: (@source, @direction = directions.null) ->


  bindTarget: (@target) ->
    @source.bindTarget(this)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    @target.receiveMessage(message)
    return this
