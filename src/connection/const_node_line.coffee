'use strict'


noop = require '../payloads/noop'


module.exports = class ConstNodeLine

  inspect: -> @direction.inspect() + @target.inspect()


  constructor: (@target, @direction, @createPayload) ->
    @createPayload ?= noop


  connect: (message) ->
    @target.connectSource(message, this)
    return this


  disconnect: (message) ->
    @target.disconnectSource(message, this)
    return this


  acceptsCommunication: (query) ->
    query.directionMatches(@direction)


  receiveQuery: (query) ->
    query.createQueryResponseMessage(@createPayload())
      .sendToNodeTarget(this, @target)
    return this
