'use strict'

{MergedPayload} = require './payloads'

module.exports = class Message

  constructor: (@transmission, @payload) ->


  getPayload: ->
    return @payload


  copyWithPayload: (payload) ->
    copy = new Message(@transmission, payload)
    return copy


  copyWithTransformedPayload: (transform) ->
    copy = new Message(@transmission, transform(@payload))
    return copy


  sendFromNode: (node) ->
    @transmission.addMessageFrom(this, node)
    node.getNodeSource().sendMessage(this)
    return this


  sendToNode: (targetNode) ->
    @payload.deliver(targetNode)
    return this


  sendMergedTo: (sourceKeys, target) ->
    mergedPayload = new MergedPayload(sourceKeys)
    for key in sourceKeys
      message = @transmission.getMessageFrom(key)
      continue unless message?
      mergedPayload.set(key, message.getPayload())

    if mergedPayload.isPresent()
      target.receive(@copyWithPayload(mergedPayload))
    return this


  enquireForMerge: (source) ->
    source.enquire(@transmission.createQuery())
    return this
