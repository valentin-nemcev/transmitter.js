'use strict'


Map = require 'collections/map'


module.exports = class MergedMessage

  inspect: ->
    [
      'MM'
      'P:' + @pass.inspect()
      @nodesToMessages.values().map( (m) -> m.inspect() ).join(', ')
    ].join(' ')


  @getOrCreate = (source, transmission, pass) ->
    merged = transmission.getCachedMessage(source)
    if not merged? or pass.compare(merged.pass) > 0
      merged = new this(transmission, source, {pass})
      transmission.setCachedMessage(source, merged)
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
      @source.sendMessage(@_mergeMessages())
    return this


  _mergeMessages: ->
    payloads = new Map(
      @nodesToMessages.map (message, node) -> [node, message.payload]
    )
    nesting = Math.max(@nodesToMessages.map((message) -> message.nesting)...)
    @transmission.Message.createMerged(this, payloads, {nesting})
