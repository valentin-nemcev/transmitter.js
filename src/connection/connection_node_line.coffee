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


  receiveQuery: (query) ->
    if query.directionMatches(@direction)
      query.addPassedLine(this)
      @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    message.sendToMergingNodeTarget(this, @target) if @target?
    return this
