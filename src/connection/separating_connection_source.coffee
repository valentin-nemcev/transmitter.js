'use strict'


{inspect} = require 'util'
Map = require 'collections/map'


module.exports = class SeparatingConnectionSource

  inspect: ->
    ':[' + @target.keys().map(inspect).join(', ') + ']'


  constructor: (@targets) ->
    @targets.forEach (target, node) => target.setSource(this)


  setSource: (@source) -> this


  connect: (message) ->
    @targets.forEach (target) -> target.connect(message)
    return this


  disconnect: (message) ->
    @targets.forEach (target) -> target.disconnect(message)
    return this


  receiveMessage: (message) ->
    message.sendSeparatedTo(@targets)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
