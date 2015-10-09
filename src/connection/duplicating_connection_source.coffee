'use strict'


{inspect} = require 'util'


module.exports = class SeparatingConnectionSource

  inspect: ->
    '=[' + @target.map(inspect).join(', ') + ']'


  constructor: (@targets) ->
    @targets.forEach (target) => target.setSource(this)


  setSource: (@source) -> this


  connect: (message) ->
    @targets.forEach (target) -> target.connect(message)
    return this


  disconnect: (message) ->
    @targets.forEach (target) -> target.disconnect(message)
    return this


  receiveMessage: (message) ->
    @targets.forEach (target) -> target.receiveMessage(message)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  getPlaceholderPayload: -> @source.getPlaceholderPayload()
