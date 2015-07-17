'use strict'


ConnectionPayload = require '../payloads/connection'


module.exports = class ChannelNode

  inspect: -> '[' + @constructor.name + ']'


  setSource: (@source) ->


  receiveConnectionMessage: (message) ->
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    message.sendToChannelNode(this)
    return this


  routeMessage: (tr, payload) ->
    @tr = tr
    @acceptPayload(payload)
    @tr = null
    return this


  connect: (channel) ->
    payload = ConnectionPayload.connect(this)
    @tr.createNextConnectionMessage(payload)
      .sendToConnection(channel)
    return this


  disconnect: (channel) ->
    payload = ConnectionPayload.disconnect(this)
    @tr.createNextConnectionMessage(payload)
      .sendToConnection(channel)
    return this
