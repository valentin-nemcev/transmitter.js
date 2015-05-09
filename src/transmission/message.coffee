'use strict'


assert = require 'assert'
MergedPayload = require '../payloads/merged'


module.exports = class Message

  inspect: -> "M #{@payload.inspect()}"


  constructor: (@transmission, @payload) ->
    assert(@payload, 'Message must have payload')


  _copyWithPayload: (payload) ->
    copy = new Message(@transmission, payload)
    return copy


  sendToConnectionWithPayload: (connection, payload) ->
    @transmission.createConnectionMessage(payload)
      .sendToConnection(connection)


  getPayload: ->
    return @payload


  sendToLine: (line) ->
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveMessage(this)
    else
      line.receiveConnectionQuery(@transmission.createQuery())
    return this


  sendToNodeTarget: (nodeTarget) ->
    return this if @transmission.hasMessageFor(nodeTarget)
    @transmission.addMessageFor(this, nodeTarget)
    nodeTarget.receiveMessage(this)
    return this


  sendToNode: (node) ->
    node.routeMessage(@payload, @transmission)
    return this


  sendToNodeSource: (nodeSource) ->
    return this if @transmission.hasMessageFor(nodeSource)
    @transmission.addMessageFor(this, nodeSource)
    nodeSource.receiveMessage(this)
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
      message = @transmission.getMessageFor(key.getNodeSource())
      continue unless message?
      mergedPayload.setAt(key, message.getPayload())

    if mergedPayload.isPresent()
      target.receiveMessage(@_copyWithPayload(mergedPayload))
    return this


  sendQueryForMerge: (source) ->
    source.receiveQuery(@transmission.createQuery())
    return this
