'use strict'


module.exports = class ConnectionNodeLine

  inspect: -> @direction.inspect() + (@target?.inspect() ? null)


  constructor: (@target, @direction) ->


  setSource: (@source) -> this


  connect: (message) ->
    @target?.connectSource(message, this)
    return this


  disconnect: (message) ->
    @target?.disconnectSource(message, this)
    return this


  acceptsCommunication: (query) ->
    query.directionMatches(@direction)


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  getPayload: -> null


  receiveMessage: (message) ->
    message.sendToNodeTarget(this, @target) if @target?
    return this
