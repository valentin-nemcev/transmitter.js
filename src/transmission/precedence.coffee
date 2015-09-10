'use strict'


{inspect} = require 'util'


class SelectPrecedence

  inspect: ->
    'SP[' + [@payloadPriority].map(inspect).join(', ') + ']'

  constructor: (@payloadPriority) ->

  compare: (other) ->
    this.payloadPriority - other.payloadPriority



module.exports =
  createSelect: (payloadPriority) ->
    new SelectPrecedence(payloadPriority)
