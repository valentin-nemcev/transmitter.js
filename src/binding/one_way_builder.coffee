'use strict'


module.exports = class BindingBuilder


  returnArg = (arg) -> arg


  constructor: ({@bindingConstructor}) ->
    @transform ?= returnArg


  fromSource: (@source) ->
    return this


  toTarget: (@target) ->
    return this


  withTransform: (@transform) ->
    return this


  bind: ->
    binding = new @bindingConstructor({@transform})
    binding.bindSourceTarget(
      @source.getMessageSender(),
      @target.getMessageReceiver()
    )
