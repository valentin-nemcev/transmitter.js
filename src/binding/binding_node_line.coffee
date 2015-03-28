'use strict'


module.exports = class BindingNodeLine

  constructor: (@target, @direction) ->


  bindSource: (@source) ->
    @target.bindSource(this)


  receiveQuery: (query) ->
    query.sendToSourceAlongDirection(@source, @direction)
    return this


  receiveMessage: (message) ->
    @target.receiveMessage(message)
    return this
