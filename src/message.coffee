'use strict'


module.exports = class Message

  constructor: (@chain) ->


  setPayload: (@payload) ->
    return this


  copyWithTransformedPayload: (transform) ->
    copy = new Message(@chain)
    copy.setPayload(transform(@payload))
    return copy


  sendFrom: (sender) ->
    @chain.addMessageFrom(this, sender)
    sender.sendMessage(this)
    return this


  sendToNode: (targetNode) ->
    @payload.deliver(targetNode)
    return this


  sendMergedTo: (target) ->
    return this


  enquireForMerge: (source) ->
    source.enquire(@chain.createQuery())
    return this
