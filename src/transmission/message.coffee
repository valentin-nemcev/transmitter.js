'use strict'

assert = require 'assert'
{MergedPayload} = require './payloads'

module.exports = class Message

  constructor: (@transmission, @payload) ->
    assert(@payload, 'Message must have payload')


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
    msg = if transform?
      @copyWithPayload(transform(@payload))
    else
      this
    target.receiveMessage(msg)
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


  sendQueryForMerge: (source, createQueryResponse) ->
    source.receiveQuery(@transmission.createQuery(createQueryResponse))
    return this
