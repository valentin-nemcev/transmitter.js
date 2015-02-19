'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
Binding = require './binding'


module.exports =

  buildOneWayBinding: -> new OneWayBindingBuilder(bindingConstructor: Binding)

  buildCompositeSource: -> new CompositeSourceBuilder()

  bind: (binding) -> binding.bind()
