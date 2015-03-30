'use strict'


directions = require './directions.coffee'


module.exports = class NodeBindingLine

  constructor: (@source, @direction = directions.null, opts = {}) ->
    {@queryForMergeWith} = opts


  bindTarget: (@target) ->
    @source.bindTarget(this)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    if @queryForMergeWith?
      message.sendQueryForMerge(@target, @queryForMergeWith)
    @target.receiveMessage(message)
    return this
