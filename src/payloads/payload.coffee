'use strict'


{inspect} = require 'util'


module.exports = class Payload

  isNoop: -> no

  replaceByNoop: (payload) ->
    if payload.isNoop() then payload else this

  replaceNoopBy: -> this
