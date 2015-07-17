'use strict'


module.exports = class ConnectionNodeLine

  inspect: -> '-' + (@target?.inspect() ? null)


  constructor: (@target, @direction) ->
    @isConnected = no


  setSource: (@source) -> this


  isConst: -> not @origin?


  connect: (@origin) ->
    @target?.connectSource(@origin, this)
    @isConnected = yes
    return this


  disconnect: ->
    @target?.disconnectSource(@origin, this)
    @isConnected = no
    return this


  receiveConnectionMessage: (message) ->
    message.sendToLine(this)
    message.passCommunication(@target, this) if @target? and @isConnected
    return this


  receiveConnectionQuery: (query) ->
    @origin.receiveQuery(query)
    return this


  receiveOutgoingMessage: ->
    return this


  receiveOutgoingQuery: (query) ->
    if query.directionMatches(@direction)
      @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    message.sendToNodeTarget(@target) if @target?
    return this
