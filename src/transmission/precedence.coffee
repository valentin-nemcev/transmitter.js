'use strict'


class UpdatePrecedence

  constructor: (@pass, @commTypePriority) ->

  compare: (other) ->
    this.pass.compare(other.pass) \
      or this.commTypePriority - other.commTypePriority


class QueuePrecedence

  constructor: (@pass, @commTypePriority, @nestingPriority) ->

  compare: (other) ->
    this.pass.compare(other.pass) \
      or this.commTypePriority - other.commTypePriority \
      or this.nestingPriority - other.nestingPriority


class SelectPrecedence

  constructor: (@payloadPriority) ->

  compare: (other) ->
    this.payloadPriority - other.payloadPriority



module.exports =
  createUpdate: (pass, commTypePriority) ->
    new UpdatePrecedence(pass, commTypePriority)
  createQueue: (pass, commTypePriority, nestingPriority) ->
    new QueuePrecedence(pass, commTypePriority, nestingPriority)
  createSelect: (payloadPriority) ->
    new SelectPrecedence(payloadPriority)
