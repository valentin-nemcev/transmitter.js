'use strict'


Payload = require './payload'


class NoopPayload


  constructor: ->

  inspect: -> "noop()"

  isNoop: -> yes

  fixedPriority: 0

  replaceByNoop: -> this

  replaceNoopBy: (payload) -> payload

  noopIf: -> this

  map: -> this

  filter: -> this

  deliverToVariable: (variable) ->
    return this

  deliverToList: (list) ->
    return this

  deliverValue: (target) ->
    return this


noopPayload = null

module.exports = ->
  noopPayload ?= new NoopPayload()
