'use strict'


Binding = require './binding'


module.exports = class BindingBuilder


  returnArg = (arg) -> arg


  constructor: ->
    @transform ?= returnArg


  fromSource: (@source) ->
    return this


  toTarget: (@target) ->
    return this


  withTransform: (@transform) ->
    return this


  bind: ->
    binding = new Binding({@transform})
    binding.bindSourceTarget(
      @source.getNodeSource(),
      @target.getNodeTarget()
    )
