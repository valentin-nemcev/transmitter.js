'use strict'

{MergedPayload} = require './payloads'

module.exports = class Message

  constructor: (@chain) ->


  setPayload: (@payload) ->
    return this


  getPayload: ->
    return @payload


  copyWithPayload: (payload) ->
    copy = new Message(@chain)
    copy.setPayload(payload)
    return copy


  copyWithTransformedPayload: (transform) ->
    copy = new Message(@chain)
    copy.setPayload(transform(@payload))
    return copy


  sendFrom: (sender) ->
    @chain.addMessageFrom(this, sender)
    sender.getMessageSender().sendMessage(this)
    return this


  sendToNode: (targetNode) ->
    @payload.deliver(targetNode)
    return this


  sendMergedTo: (sourceKeys, target) ->
    mergedPayload = new MergedPayload(sourceKeys)
    for key in sourceKeys
      message = @chain.getMessageFrom(key)
      continue unless message?
      mergedPayload.set(key, message.getPayload())

    if mergedPayload.isPresent()
      target.receive(@copyWithPayload(mergedPayload))
    return this


  enquireForMerge: (source) ->
    source.enquire(@chain.createQuery())
    return this
