'use strict'


Map = require 'collections/map'

Nesting = require './nesting'


module.exports = class MergedMessage

  inspect: ->
    [
      'MM'
      inspect @nesting
      inspect @pass
      @nodesToMessages.values().map(inspect).join(', ')
    ].join(' ')


  @getOrCreate = (source, transmission, pass, nesting) ->
    merged = transmission.getCachedMessage(source)
    unless (merged? and pass.equals(merged.pass))
      merged = new this(transmission, source, {pass, nesting})
      transmission.setCachedMessage(source, merged)
    return merged


  constructor: (@transmission, @source, opts = {}) ->
    {@pass, @nesting} = opts
    @nodesToMessages = new Map()


  receiveMessageFrom: (message, node, target) ->
    if @nodesToMessages.length is 0
      @source.receiveQuery(@transmission.Query.createForMerge(this))

    @nodesToMessages.set(node, message)

    # TODO: Compare contents
    if @nodesToMessages.length == @source.getSourceNodes().length
      @source.sendMessage(@_mergeMessages(@source.getSourceNodes()))
    return this


  _mergeMessages: (sourceNodes) ->
    payloads = new Map(
      sourceNodes.map (node) => [node, @nodesToMessages.get(node)?.payload]
    )
    nesting = Nesting.merge @nodesToMessages.map((message) -> message.nesting)
    @transmission.log this
    @transmission.Message.createMerged(this, payloads, {nesting})
