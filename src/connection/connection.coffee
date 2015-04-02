'use strict'


module.exports = class Connection

  constructor: (@transform) ->


  connectSourceTarget: (@source, @target) ->
    @source.connectTarget(this)
    @target.connectSource(this)
    return this


  receiveMessage: (message) ->
    message.sendTransformedTo(@transform, @target)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
