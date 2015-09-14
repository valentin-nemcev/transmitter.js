'use strict'

{inspect} = require 'util'

Map = require 'collections/map'
noop = require '../payloads/noop'


module.exports = class MergedMessage

  inspect: ->
    [
      'MM'
      inspect @pass
      @nodesToMessages.values().map(inspect).join(', ')
    ].join(' ')


  @getOrCreate = (message, source) ->
    {transmission, pass} = message
    merged = transmission.getCommunicationFor(pass, source)
    unless (merged? and pass.equals(merged.pass))
      merged = new this(transmission, source, {pass})
      transmission.addCommunicationFor(merged, source)
    return merged


  constructor: (@transmission, @source, opts = {}) ->
    {@pass} = opts
    @nodesToMessages = new Map()


  receiveMessageFrom: (message, node, target) ->
    if @nodesToMessages.length is 0
      @source.receiveQuery(@transmission.Query.createForMerge(this))

    @nodesToMessages.set(node, message)

    # TODO: Compare contents
    if @nodesToMessages.length == @source.getSourceNodes().length
      if @source.prioritiesShouldMatch and not @_prioritiesMatch()
        payload = noop()
        priority = null
      else
        [payload, priority] = @_getMergedPayload(@source.getSourceNodes())
      message = @transmission.Message.createMerged(this, payload)
      message.setPriority(priority)
      @source.sendMessage(message)
    return this


  _prioritiesMatch: ->
    priorities = @nodesToMessages.map (msg) -> msg.getPriority()
    priorities.every (p) -> p == priorities[0]


  _getMergedPayload: (sourceNodes) ->
    @transmission.log this
    payload = new Map()
    priority = null
    sourceNodes.forEach (node) =>
      message = @nodesToMessages.get(node)
      payload.set(node, message?.payload)
      priority = Math.max(message?.getPriority(), priority)
    return [payload, priority]
