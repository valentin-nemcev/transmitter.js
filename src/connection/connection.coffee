'use strict'


module.exports = class Connection

  constructor: (@source, @target, @transform) ->
    @source.setTarget(this)
    @target.setSource(this)

  inspect: -> @source.inspect() + @target.inspect()


  receiveConnectionMessage: (message) ->
    @source.receiveConnectionMessage(message)
    @target.receiveConnectionMessage(message)
    return this


  receiveMessage: (message) ->
    message.sendTransformedTo(@transform, @target)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
