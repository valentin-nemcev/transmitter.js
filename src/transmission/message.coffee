'use strict'

assert = require 'assert'
{MergedPayload} = require './payloads'

module.exports = class Message

  constructor: (@transmission, @payload) ->
    assert(@payload, 'Message must have payload')


  _copyWithPayload: (payload) ->
    copy = new Message(@transmission, payload)
    return copy


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
      copy = @_copyWithPayload(@payload)
      node.getNodeSource().receiveMessage(copy)
    return this


  sendTransformedTo: (transform, target) ->
    copy = if transform?
      @_copyWithPayload(transform(@payload))
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
      target.receiveMessage(@_copyWithPayload(mergedPayload))
    return this


  sendQueryForMerge: (source, createQueryResponse) ->
    source.receiveQuery(@transmission.createQuery(createQueryResponse))
    return this
