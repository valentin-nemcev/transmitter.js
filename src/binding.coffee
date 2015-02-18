'use strict'


module.exports = class Binding

  idFunc = (arg) -> arg


  constructor: ({@source, @target, @transform}) ->
    @transform ?= idFunc


  bind: ->
    @source.bindTarget(this)
    return this


  send: (message) ->
    @target.send(@transform.call(null, message))
    return this
