'use strict'


class exports.EventPayload

  toValue: (value) -> new exports.ValuePayload(value)


class exports.ValuePayload

  constructor: (@value) ->

  deliver: (target) ->
    target.receiveValue(@value)
    return this
