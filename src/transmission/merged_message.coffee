'use strict'

{inspect} = require 'util'

Map = require 'collections/map'


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
      @source.sendMessage(@_mergeMessages(@source.getSourceNodes()))
    return this


  _mergeMessages: (sourceNodes) ->
    @transmission.log this
    payloads = new Map \
      sourceNodes.map((node) => [node, @nodesToMessages.get(node)?.payload])
    @transmission.Message.createMerged(this, payloads)
