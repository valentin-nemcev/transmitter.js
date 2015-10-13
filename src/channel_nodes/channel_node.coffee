'use strict'


FastSet = require 'collections/fast-set'


module.exports = class ChannelNode

  inspect: -> '[' + @constructor.name + ']'

  isConnectionTarget: -> yes


  setSource: (@source) ->


  getTargetPoints: ->
    @targetPoints ?= new FastSet()


  addTargetPoint: (targetPoint) ->
    @getTargetPoints().add(targetPoint)
    return this


  removeTargetPoint: (targetPoint) ->
    @getTargetPoints().delete(targetPoint)
    return this


  connect: (message) ->
    message.addTargetPoint(this)

    if (payload = @getPlaceholderPayload())?
      @message = message.createPlaceholderConnectionMessage(this)
      @acceptPayload(payload)
      @message = null
    return this


  receiveConnectionMessage: (connectionMessage) ->
    connectionMessage.createNextQuery()
      .sendToChannelNode(this)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this


  receiveMessage: (message) ->
    message.sendToChannelNode(this)
    return this


  routeMessage: (tr, payload) ->
    @message = tr.createNextConnectionMessage(this)
    @acceptPayload(payload)
    @message.sendToTargetPoints()
    @message = null
    return this


  getPlaceholderPayload: ->
    @source.getPlaceholderPayload()

  getSourcePayload: -> null

  getTargetPayload: -> null
