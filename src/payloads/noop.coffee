'use strict'


class NoopPayload

  constructor: ->

  inspect: -> "noop()"

  deliverToVariable: (variable) ->
    return this

  deliverToList: (list) ->
    return this

  deliverValue: (target) ->
    return this


noopPayload = null

module.exports = ->
  noopPayload ?= new NoopPayload()
