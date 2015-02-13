'use strict'


module.exports = class Binding

  idFunc = (arg) -> arg


  constructor: ({@source, @target, @transform}) ->
    @transform ?= idFunc


  bind: ->
    @source.attachOutgoingBinding(this)
    @target.attachIncomingBinding(this)
    return this


  propagate: (message) ->
    @target.propagate(@transform.call(null, message))
    return this
