'use strict'

{inspect} = require 'util'

Map = require 'collections/map'
noop = require '../payloads/noop'
{merge} = require '../payloads/variable'


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


  joinQuery: (query) ->
    unless @query?
      @query = query
      if @source.getSourceNodes().length is 0
        @_sendMessage(@_getEmptyPayload())
      else
        @source.sendQuery(@query)
    return this


  joinMessageFrom: (message, node) ->
    unless @query?
      @query = @transmission.Query.createNext(this)
      @source.sendQuery(@query)

    @nodesToMessages.set(node, message)

    # TODO: Compare contents
    if @nodesToMessages.length == @source.getSourceNodes().length
      [payload, priority] = if @source.prioritiesShouldMatch and not @_prioritiesMatch()
        @_getNoopPayload()
      else
        @_getMergedPayload(@source.getSourceNodes())
      @_sendMessage([payload, priority])
    return this


  _prioritiesMatch: ->
    priorities = @nodesToMessages.map (msg) -> msg.getPriority()
    priorities.every (p) -> p == priorities[0]


  _sendMessage: ([payload, priority]) ->
    message = @transmission.Message.createNext(this, payload, priority)
    @source.sendMessage(message)
    return this


  _getNoopPayload: -> [noop(), null]


  _getEmptyPayload: ->
    payload = []
    payload.merge = -> merge(this)
    [payload, 0]


  _getMergedPayload: (sourceNodes) ->
    @transmission.log this
    payload = []
    payload.merge = -> merge(this)
    priority = null
    sourceNodes.forEach (node) =>
      message = @nodesToMessages.get(node)
      priority = Math.max(priority, message.getPriority())
      payload.push message.payload
    return [payload, priority]
