'use strict'

{inspect} = require 'util'

Map = require 'collections/map'
noop = require '../payloads/noop'
{merge} = require '../payloads/variable'


SeparatedMessage = require './separated_message'


module.exports = class MergedMessage

  inspect: ->
    [
      'MM'
      inspect @pass
      @nodesToMessages.values().map(inspect).join(', ')
    ].join(' ')


  log: ->
    args = [this]
    args.push arg for arg in arguments
    @transmission.log args...
    return this


  @getOrCreate = (message, source) ->
    {transmission, pass} = message
    merged = transmission.getCommunicationFor(pass, source)
    unless (merged? and pass.equals(merged.pass))
      merged = new this(transmission, pass, source)
      transmission.addCommunicationFor(merged, source)
    return merged


  createNextConnectionMessage: (channelNode) ->
    @transmission.ConnectionMessage.createNext(this, channelNode)


  constructor: (@transmission, @pass, @source) ->
    @nodesToMessages = new Map()


  joinConnectionMessage: (message) ->
    @sourceChannelNode = message.getSourceChannelNode()
    return this


  joinQuery: (query) ->
    unless @query?
      @query = query
      if @source.getSourceNodes().length is 0
        [@payload, @priority] = @_getEmptyPayload()
        @source.sendMessage(this)
      else
        @source.sendQuery(@query)
    return this


  joinMessageFrom: (message, node) ->
    unless @query? or @source.singleSource
      @query = @transmission.Query.createNext(this)
      @source.sendQuery(@query)

    @nodesToMessages.set(node, message)

    # TODO: Compare contents
    unless @nodesToMessages.length == @source.getSourceNodes().length
      return this

    [@payload, @priority] =
      if @source.prioritiesShouldMatch and not @_prioritiesMatch()
        @_getNoopPayload()
      else
        @_getMergedPayload()
    @source.sendMessage(this)


  _prioritiesMatch: ->
    priorities = @nodesToMessages.map (msg) -> msg.getPriority()
    priorities.every (p) -> p == priorities[0]


  getPayload: (args...) ->
    @transformedPayload ?= if @transform?
      @transform.apply(null, [@payload, args..., @transmission])
    else
      @payload

  getPriority: -> @priority


  addTransform: (@transform) ->
    return this


  joinSeparatedMessage: (target) ->
    SeparatedMessage
      .getOrCreate(this, target)
      .joinMessage(this)
    return this


  sendToChannelNode: (node) ->
    @log node
    existing = @transmission.getCommunicationFor(@pass, node)
    existing ?= @transmission.getCommunicationFor(@pass.getNext(), node)
    if existing?
      throw new Error "Message already sent to #{inspect node}. " \
        + "Previous: #{inspect existing}, " \
        + "current: #{inspect this}"
    @transmission.addCommunicationFor(this, node)
    node.routeMessage(this, @getPayload())
    return this


  _getNoopPayload: -> [noop(), null]


  _getEmptyPayload: ->
    payload = @sourceChannelNode?.getSourcePayload() ? []
    [payload, 0]


  _getMergedPayload: ->
    @transmission.log this
    srcPayload = @sourceChannelNode?.getSourcePayload() ? @source.getSourceNodes()

    priority = null
    @nodesToMessages.forEach (message, node) =>
      priority = Math.max(priority, message.getPriority())

    payload = srcPayload.map (node) =>
      @nodesToMessages.get(node).getPayload()

    payload = payload[0] if @source.singleSource

    return [payload, priority]
