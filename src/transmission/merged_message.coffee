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
      merged = new this(transmission, pass, source)
      transmission.addCommunicationFor(merged, source)
    return merged


  constructor: (@transmission, @pass, @source) ->
    @nodesToMessages = new Map()


  receiveMessageFrom: (message, node, target) ->
    if @nodesToMessages.length is 0
      @source.receiveQuery(@transmission.Query.createNext(this))

    @nodesToMessages.set(node, message)

    # TODO: Compare contents
    if @nodesToMessages.length == @source.getSourceNodes().length
      if @source.prioritiesShouldMatch and not @_prioritiesMatch()
        payload = noop()
        priority = null
      else
        [payload, priority] = @_getMergedPayload(@source.getSourceNodes())
      message = @transmission.Message.createNext(this, payload, priority)
      @source.sendMessage(message)
    return this


  _prioritiesMatch: ->
    priorities = @nodesToMessages.map (msg) -> msg.getPriority()
    priorities.every (p) -> p == priorities[0]


  merge = ->
    this[0].merge(this.slice(1)...)

  _getMergedPayload: (sourceNodes) ->
    @transmission.log this
    payload = []
    payload.merge = merge
    priority = null
    sourceNodes.forEach (node) =>
      message = @nodesToMessages.get(node)
      priority = Math.max(priority, message.getPriority())
      payload.push message.payload
    return [payload, priority]
