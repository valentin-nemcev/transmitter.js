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
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveMessage(this)
    else
      line.receiveConnectionQuery(@transmission.getSender().createQuery())
    return this


  sendFromSourceNode: (node) ->
    return this if @transmission.hasMessageFor(node)
    @transmission.addMessageFor(this, node)
    node.getNodeSource().receiveMessage(this)
    return this


  sendToTargetNode: (node) ->
    return this if @transmission.hasMessageFor(node)
    @payload.deliver(node)
    if node.getNodeSource?
      node.getResponseMessage(@transmission.getSender()).sendFromSourceNode(node)
    else
      @transmission.addMessageFor(this, node)
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
      message = @transmission.getMessageFor(key)
      continue unless message?
      mergedPayload.set(key, message.getPayload())

    if mergedPayload.isPresent()
      target.receiveMessage(@_copyWithPayload(mergedPayload))
    return this


  sendQueryForMerge: (source) ->
    source.receiveQuery(@transmission.getSender().createQuery())
    return this
