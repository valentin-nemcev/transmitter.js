'use strict'


Binding = require '../binding'
CompositeSourceBuilder = require './composite_source_builder'


module.exports = class BindingBuilder

  @build = ->
    new this(
      bindingConstructor: Binding,
      buildCompositeSource: CompositeSourceBuilder.build
    )


  returnArg = (arg) -> arg


  constructor: ({@bindingConstructor, @buildCompositeSource}) ->
    @transform ?= returnArg


  fromSource: (@source) ->
    return this


  fromCompositeSource: (defineCompositeSource) ->
    compositeSourceBuilder = @buildCompositeSource()
    defineCompositeSource(compositeSourceBuilder)
    @source = compositeSourceBuilder.create()
    return this


  toTarget: (@target) ->
    return this


  withTransform: (@transform) ->
    return this


  bind: ->
    binding = new @bindingConstructor({@transform})
    binding.bindSourceTarget(@source, @target)
