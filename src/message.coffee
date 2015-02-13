'use strict'


module.exports = class Message

  @createBare = -> new BareMessage

  toValueMessage: -> new ValueMessage(arguments...)


class BareMessage extends Message


class ValueMessage extends Message

  constructor: (@value) ->

  propagateTo: (target) ->
    target.receiveValue(@value)
    return this
