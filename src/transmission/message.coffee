'use strict'

assert = require 'assert'
{MergedPayload} = require './payloads'

module.exports = class Message

  constructor: (@transmission, @payload) ->
    assert(@payload, 'Message must have payload')


  getPayload: ->
    return @payload


  sendFromSourceNode: (node) ->
    return this if @transmission.hasMessageForNode(node)
    @transmission.addMessageForNode(this, node)
    node.getNodeSource().receiveMessage(this)
    return this


  sendToTargetNode: (node) ->
    return this if @transmission.hasMessageForNode(node)
    @transmission.addMessageForNode(this, node)
    @payload.deliver(node)
    if node.getNodeSource?
      copy = @copyWithPayload(@payload)
      node.getNodeSource().receiveMessage(copy)
    return this


  copyWithPayload: (payload) ->
    copy = new Message(@transmission, payload)
    return copy


  sendTransformedTo: (transform, target) ->
    copy = if transform?
      @copyWithPayload(transform(@payload))
    else
      this
    target.receiveMessage(copy)
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
