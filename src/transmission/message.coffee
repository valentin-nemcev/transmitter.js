'use strict'


{inspect} = require 'util'

MergedMessage = require './merged_message'
TargetMessage = require './target_message'

Precedence = require './precedence'


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


  @createNext = (prevMessage, payload, priority) ->
    new this(prevMessage.transmission, prevMessage.pass, payload, priority)


  @createTarget = (prevMessage, transform) ->
    TargetMessage.create(prevMessage, transform)


  constructor: (@transmission, @pass, @payload, @priority) ->
    throw new Error "Missing payload" unless @payload?


  # TODO: Refactor
  getSelectPrecedence: ->
    @selectPrecedence ?= Precedence.createSelect(@getPriority())


  directionMatches: (direction) -> @pass.directionMatches(direction)


  getPriority: ->
    @payload.fixedPriority ? @priority


  getPayload: -> @payload


  sendToLine: (line) ->
    @log line
    line.receiveMessage(this)
    return this


  sendTransformedTo: (transform, target) ->
    target.receiveMessage(Message.createTarget(this, transform))
    return this


  joinMergedMessage: (source) ->
    MergedMessage
      .getOrCreate(this, source)
      .joinMessageFrom(this, @sourceNode)

    return this
