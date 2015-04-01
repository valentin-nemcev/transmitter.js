'use strict'


directions = require './directions.coffee'


module.exports = class NodeBindingLine

  constructor: (@source, @direction = directions.null, opts = {}) ->
    {@queryForMerge} = opts


  bindTarget: (@target) ->
    @source.bindTarget(this)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    if @queryForMerge
      message.sendQueryForMerge(@target)
    @target.receiveMessage(message)
    return this
