'use strict'

{StatePayload, MergedPayload} = require './payloads'

module.exports = class Message

  constructor: (@transmission, @payload) ->


  getPayload: ->
    return @payload


  sendFromSourceNode: (node) ->
    @transmission.addMessageFrom(this, node)
    node.getNodeSource().receiveMessage(this)
    return this


  sendToTargetNode: (targetNode) ->
    @payload.deliver(targetNode)
    return this


  copyWithPayload: (payload) ->
    copy = new Message(@transmission, payload)
    return copy


  sendTransformedTo: (transform, target) ->
    target.receiveMessage(@copyWithPayload(transform(@payload)))
    return this


  sendMergedTo: (sourceKeys, target) ->
    mergedPayload = new MergedPayload(sourceKeys)
    for key in sourceKeys
      message = @transmission.getMessageFrom(key)
      continue unless message?
      mergedPayload.set(key, message.getPayload())

    if mergedPayload.isPresent()
      target.receiveMessage(@copyWithPayload(mergedPayload))
    return this


  sendQueryForMerge: (source) ->
    source.receiveQuery(@transmission.createQuery(StatePayload.create))
    return this
