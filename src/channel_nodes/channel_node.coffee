'use strict'


ConnectionPayload = require '../payloads/connection'


module.exports = class ChannelNode


  setSource: (@source) ->


  receiveConnectionMessage: (message) ->
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  receiveMessage: (@message) ->
    @message.sendToNode(this)
    return this


  routeMessage: (payload, tr) ->
    @tr = tr
    payload.deliver(this)
    @tr = null
    return this


  connect: (channel) ->
    payload = ConnectionPayload.connect(this)
    @tr.createConnectionMessage(payload)
      .sendToConnection(channel)
    return this
