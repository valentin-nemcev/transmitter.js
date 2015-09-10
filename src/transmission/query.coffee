'use strict'


{inspect} = require 'util'

FastSet = require 'collections/fast-set'
Pass = require './pass'
Precedence = require './precedence'


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
    new this(prevQuery.transmission, {
      pass: prevQuery.pass
    })


  @createNextConnection = (prevMessageOrQuery) ->
    new this(prevMessageOrQuery.transmission, {
      pass: prevMessageOrQuery.pass
    })


  @createForMerge = (mergedMessage) ->
    new this(mergedMessage.transmission, {
      pass: mergedMessage.pass
    })


  constructor: (@transmission, opts = {}) ->
    {@pass} = opts
    @passedLines = new FastSet()
    @queriedChannelNodes = new FastSet()


  createQueryResponseMessage: (payload) ->
    @transmission.Message.createQueryResponse(this, payload)



  directionMatches: (direction) -> @pass.directionMatches(direction)


  getPassedLines: -> @passedLines


  sendToLine: (line) ->
    @log line
    @passedLines.add(line)
    line.receiveQuery(this)
    return this


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
