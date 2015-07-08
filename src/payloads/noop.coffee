'use strict'


class NoopPayload

  constructor: ->

  inspect: -> "listNoOp()"

  deliverListState: (target) ->
    return this

  deliverValueState: (target) ->
    return this

  deliverValue: (target) ->
    return this


noopPayload = null

module.exports = ->
  noopPayload ?= new NoopPayload()
