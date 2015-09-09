'use strict'


{inspect} = require 'util'


class QueuePrecedence

  inspect: ->
    'QP[' + @pass + ']'

  constructor: (@pass) ->

  compare: (other) ->
    this.pass.compare(other.pass)


class SelectPrecedence

  inspect: ->
    'SP[' + [@payloadPriority].map(inspect).join(', ') + ']'

  constructor: (@payloadPriority) ->

  compare: (other) ->
    this.payloadPriority - other.payloadPriority



module.exports =
  createQueue: (pass) ->
    new QueuePrecedence(pass)
  createSelect: (payloadPriority) ->
    new SelectPrecedence(payloadPriority)
