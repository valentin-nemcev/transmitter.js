'use strict'

{inspect} = require 'util'


module.exports = class MergedMessage
  inspect: ->
    [
      'SM'
      inspect @pass
      @nodesToMessages.values().map(inspect).join(', ')
    ].join(' ')


  @getOrCreate = (message, source) ->
    {transmission, pass} = message
    merged = transmission.getCommunicationFor(pass, source)
    unless (merged? and pass.equals(merged.pass))
      merged = new this(transmission, pass, source)
      transmission.addCommunicationFor(merged, source)
    return merged


  constructor: (@transmission, @pass, @source) ->


  joinConnectionMessage: (message) ->
    @sourceChannelNode = message.getSourceChannelNode()
    return this


  joinMessage: (message) ->
    srcPayload = @sourceChannelNode?.getPayload()
    unless srcPayload?
      srcPayload = @source.getTargets().keys()

    msgPriority = message.getPriority()
    msgPayload = message.payload

    nodesToLines = @source.getTargets()
    if srcPayload.length?
      zippedPayload = for targetNode, i in srcPayload
        target = nodesToLines.get(targetNode)
        [target, msgPayload[i]]
    else
      zippedPayload = for targetNode, i in srcPayload.get()
        target = nodesToLines.get(targetNode)
        value = msgPayload.getAt(i)
        payload = targetNode.createUpdatePayload(value)
        [target, payload]

    zippedPayload.forEach ([target, payload]) =>
      msg = @transmission.Message
        .createNext(this, payload, msgPriority)
      target.receiveMessage(msg)

    return this
