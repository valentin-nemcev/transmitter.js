'use strict'


{inspect} = require 'util'
Map = require 'collections/map'


module.exports = class SeparatingConnectionSource

  inspect: ->
    ':[' + @targets.keys().map(inspect).join(', ') + ']'


  constructor: (@targets, opts = {}) ->
    {@singleTarget} = opts
    @targets.forEach (target, node) => target.setSource(this)


  getTargets: -> @targets


  setSource: (@source) -> this


  connect: (message) ->
    @targets.forEach (target) -> target.connect(message)
    message.joinSeparatedMessage(this)
    return this


  disconnect: (message) ->
    @targets.forEach (target) -> target.disconnect(message)
    return this


  receiveMessage: (message) ->
    message.joinSeparatedMessage(this)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
