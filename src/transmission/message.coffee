'use strict'


assert = require 'assert'
{MergedPayload} = require './payloads'
ConnectionMessage = require './connection_message'


module.exports = class Message

  inspect: -> "M #{@payload.inspect()}"


  constructor: (@transmission, @payload) ->
    assert(@payload, 'Message must have payload')


  _copyWithPayload: (payload) ->
    copy = new Message(@transmission, payload)
    return copy


  sendToConnectionWithPayload: (connection, payload) ->
    new ConnectionMessage(@transmission, payload)
      .sendToConnection(connection)


  getPayload: ->
    return @payload


  sendToLine: (line) ->
    if line.isConst() or @transmission.hasMessageForNode(line)
      line.receiveMessage(this)
    else if not line.isConst()
      line.receiveConnectionQuery(@transmission.createQuery())
    return this


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
      payload = node.createRelayPayload(@payload)
      copy = @_copyWithPayload(payload)
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


  sendQueryForMerge: (source) ->
    source.receiveQuery(@transmission.createQuery())
    return this
