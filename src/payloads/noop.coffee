'use strict'


class NoopPayload

  constructor: ->

  inspect: -> "noop()"

  fixedPriority: 0

  setPriority: -> this

  getPriority: -> 0

  deliverToVariable: (variable) ->
    return this

  deliverToList: (list) ->
    return this

  deliverValue: (target) ->
    return this


noopPayload = null

module.exports = ->
  noopPayload ?= new NoopPayload()
