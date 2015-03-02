'use strict'


module.exports = class Message

  @createBare = () -> new BareMessage()

  @createValue = (value) -> new ValueMessage(value)

  toValueMessage: (value) -> new ValueMessage(value)

  getChain: -> @chain

  setChain: (@chain) -> this


  markAsSentFrom: (sender) ->
    @getChain().addMessageFrom(this, sender)
    return this


class BareMessage extends Message


class ValueMessage extends Message

  constructor: (@value) ->

  deliver: (target) ->
    target.receiveValue(@value)
    return this
