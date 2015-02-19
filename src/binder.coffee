'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
TwoWayBindingBuilder = require './two_way/binding_builder'
Binding = require './binding'


module.exports = new class Binder

  buildTwoWayBinding: -> new TwoWayBindingBuilder(this)

  buildOneWayBinding: -> new OneWayBindingBuilder(bindingConstructor: Binding)

  buildCompositeSource: -> new CompositeSourceBuilder()

  bind: (binding) -> binding.bind()
