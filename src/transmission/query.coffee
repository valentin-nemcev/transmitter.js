'use strict'


{inspect} = require 'util'

FastSet = require 'collections/fast-set'
Pass = require './pass'
Precedence = require './precedence'

MergedMessage = require './merged_message'


module.exports = class Query

  inspect: ->
    [
      'Q',
      inspect @pass
      @wasDelivered() and 'D' or ''
    ].filter( (s) -> s.length).join(' ')


  log: ->
    args = [this]
    args.push arg for arg in arguments
    @transmission.log args...
    return this


  @createNext = (prevQuery) ->
    new this(prevQuery.transmission, prevQuery.pass)


  @createNextConnection = (prevMessageOrQuery) ->
    new this(prevMessageOrQuery.transmission, prevMessageOrQuery.pass)


  constructor: (@transmission, @pass) ->
    @passedLines = new FastSet()
    @queriedChannelNodes = new FastSet()


  createQueryResponseMessage: (payload) ->
    @transmission.Message.createNext(this, payload)



  directionMatches: (direction) -> @pass.directionMatches(direction)


  getPassedLines: -> @passedLines


  sendToLine: (line) ->
    @log line
    @passedLines.add(line)
    line.receiveQuery(this)
    return this


  joinMergedMessage: (source) ->
    MergedMessage
      .getOrCreate(this, source)
      .joinQuery(this)


  sendToNodeSource: (line, nodeSource) ->
    @transmission.JointMessage
      .getOrCreate(this, {nodeSource})
      .joinQueryFrom(this, line)
    return this


  sendToChannelNode: (node) ->
    @log node
    node.receiveQuery(this)
    return this


  wasDelivered: ->
    @passedLines.length > 0
