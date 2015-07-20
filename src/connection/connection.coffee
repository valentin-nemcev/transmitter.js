'use strict'


module.exports = class Connection

  constructor: (@source, @target, @transform) ->
    @source.setTarget(this)
    @target.setSource(this)

  inspect: -> @source.inspect() + @target.inspect()


  connect: (message) ->
    @source.connect(message)
    @target.connect(message)
    return this


  disconnect: (message) ->
    @source.disconnect(message)
    @target.disconnect(message)
    return this


  receiveMessage: (message) ->
    message.sendTransformedTo(@transform, @target)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
