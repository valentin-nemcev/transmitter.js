'use strict'


module.exports = class Message

  @createBare = -> new BareMessage

  @createValue = (value) -> new ValueMessage(value)

  toValueMessage: -> new ValueMessage(arguments...)


class BareMessage extends Message


class ValueMessage extends Message

  constructor: (@value) ->

  deliver: (target) ->
    target.receiveValue(@value)
    return this