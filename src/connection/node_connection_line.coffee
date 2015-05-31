'use strict'



module.exports = class NodeConnectionLine

  inspect: -> (@source?.inspect() ? null) + '-'


  constructor: (@source, @direction) ->


  setTarget: (@target) -> this


  isConst: -> not @origin?


  setOrigin: (@origin) -> this


  connect: ->
    @source?.connectTarget(this)
    return this


  receiveConnectionMessage: (message) ->
    message.sendToLine(this)
    @source?.receiveConnectionMessageFrom(message, this)
    return this


  receiveConnectionQuery: (query) ->
    query.setDirection(@direction)
    @origin.receiveQuery(query)
    return this


  receiveQuery: (query) ->
    query.sendToNodeSource(@source) if @source?
    return this


  receiveMessage: (message) ->
    @target.receiveMessage(message)
    return this
