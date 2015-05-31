'use strict'


assert = require 'assert'
MergedPayload = require '../payloads/merged'


module.exports = class Message

  inspect: -> "M #{@payload.inspect()}"


  constructor: (@transmission, @payload, opts = {}) ->
    @precedence = opts.precedence
    assert(@payload, 'Message must have payload')


  createNextQuery: ->
    @transmission.createQuery({@precedence})


  createNextMessage: (payload) ->
    @transmission.createMessage(payload, {@precedence})


  createNextConnectionMessage: (payload) ->
    @transmission.createConnectionMessage(payload, {@precedence})


  getPayload: ->
    return @payload


  sendToLine: (line) ->
    if line.isConst() or @transmission.hasMessageFor(line)
      line.receiveMessage(this)
    else
      line.receiveConnectionQuery(@createNextQuery())
    return this


  hasPrecedenceOver: (prev) ->
    not prev? or this.precedence > prev.precedence


  _sendToNodePoint: (point) ->
    return this unless @hasPrecedenceOver(@transmission.getMessageFor(point))
    @transmission.addMessageFor(this, point)
    point.receiveMessage(this)
    return this


  sendToNodeTarget: (nodeTarget) -> @_sendToNodePoint(nodeTarget)


  sendToNode: (node) ->
    node.routeMessage(this, @payload)
    return this


  sendToNodeSource: (nodeSource) -> @_sendToNodePoint(nodeSource)


  sendTransformedTo: (transform, target) ->
    copy = if transform?
      @createNextMessage(transform(@payload, @transmission))
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
      target.receiveMessage(@createNextMessage(mergedPayload))
    return this


  sendQueryForMerge: (source) ->
    source.receiveQuery(@createNextQuery())
    return this
