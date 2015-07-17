'use strict'


module.exports = class NodeConnectionLine

  inspect: -> (@source?.inspect() ? null) + '-'


  constructor: (@source, @direction) ->
    @isConnected = no


  setTarget: (@target) -> this


  isConst: -> not @origin?


  connect: (@origin) ->
    @source?.connectTarget(@origin, this)
    @isConnected = yes
    return this


  disconnect: ->
    @source?.disconnectTarget(@origin, this)
    @isConnected = no
    return this


  receiveConnectionMessage: (message) ->
    message.sendToLine(this)
    message.passCommunication(@source, this) if @source? and @isConnected
    return this


  receiveConnectionQuery: (query) ->
    @origin.receiveQuery(query)
    return this


  receiveQuery: (query) ->
    query.sendToNodeSource(@source) if @source?
    return this


  receiveOutgoingQuery: ->
    return this


  receiveOutgoingMessage: (message) ->
    if message.directionMatches(@direction)
      @target.receiveMessage(message)
    return this
