'use strict'


module.exports = class Binding

  idFunc = (arg) -> arg


  constructor: ({@source, @target, @transform}) ->
    @transform ?= idFunc


  bind: ->
    @source.attachOutgoingBinding(this)
    return this


  send: (message) ->
    @target.send(@transform.call(null, message))
    return this
