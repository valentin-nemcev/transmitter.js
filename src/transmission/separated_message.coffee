'use strict'

{inspect} = require 'util'


Map = require 'collections/map'


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


  getPriority: -> @sourceMessage.getPriority()


  joinMessage: (message) ->
    @sourceMessage = message

    nodesToLines = @source.getTargets()
    srcPayload = @sourceChannelNode?.getPayload() ? nodesToLines.keys()
    payload = message.getPayload(srcPayload)

    @_combinePayload(nodesToLines, payload, srcPayload)
      .forEach (payload, target) =>
        target.receiveMessage(message.createSeparate(this, payload))

    return this


  _combinePayload: (nodesToLines, payload, srcPayload) ->
    if srcPayload.length?
      zippedPayload = for targetNode, i in srcPayload
        target = nodesToLines.get(targetNode)
        [target, payload[i]]
    else
      zippedPayload = for targetNode, i in srcPayload.get()
        target = nodesToLines.get(targetNode)
        [target, payload.getAt(i)]

    nonNull = zippedPayload.filter ([target, payload]) -> payload?
    if nonNull.length != zippedPayload.length
      throw new Error "Payload element count mismatch, " \
        + "expected #{zippedPayload.length}, " \
        + "got #{nonNull.length}"

    targetsToPayloads = new Map()
    zippedPayload.forEach ([target, payload]) =>
      existingPayload = targetsToPayloads.get(target)
      if existingPayload? && existingPayload != payload
        throw new Error "Payload already set for #{inspect target}. " \
          + "Previous #{inspect existingPayload}, " \
          + "current #{inspect payload}"
      targetsToPayloads.set(target, payload)

    return targetsToPayloads
