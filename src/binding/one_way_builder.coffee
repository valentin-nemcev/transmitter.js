'use strict'


Binding = require '../binding'


module.exports = class BindingBuilder

  @build = ->
    new this(
      bindingConstructor: Binding,
    )


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
      @source.getMessageSource(),
      @target.getMessageTarget()
    )
