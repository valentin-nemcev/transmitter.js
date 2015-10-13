'use strict'


{inspect} = require 'util'

MergedMessage = require './merged_message'
TargetMessage = require './target_message'


module.exports = class Message

  inspect: ->
    [
      'M'
      inspect @pass
      @payload.inspect()
    ].filter( (s) -> s.length).join(' ')


  log: ->
    args = [this]
    args.push arg for arg in arguments
    @transmission.log args...
    return this


  @create = (prevMessage, payload, priority) ->
    new this(prevMessage.transmission, prevMessage.pass, payload, priority)


  constructor: (@transmission, @pass, @payload, @priority) ->
    throw new Error "Missing payload" unless @payload?


  directionMatches: (direction) -> @pass.directionMatches(direction)


  sendToLine: (line) ->
    @log line
    line.receiveMessage(this)
    return this


  joinMergedMessage: (source) ->
    MergedMessage
      .getOrCreate(this, source)
      .joinMessageFrom(this, @sourceNode)
    return this


  getPriority: ->
    @payload.fixedPriority ? @priority


  getPayload: -> @payload
