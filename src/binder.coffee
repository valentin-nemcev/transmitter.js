'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
TwoWayBindingBuilder = require './two_way/binding_builder'
Binding = require './binding'

MessageSender = require './message/sender'
MessageReceiver = require './message/receiver'



module.exports = new class Binder

  extendWithMessageSender: (cls) ->
    MessageSender.extend(cls)
    return this

  extendWithMessageReceiver: (cls) ->
    MessageReceiver.extend(cls)
    return this

  buildTwoWayBinding: -> new TwoWayBindingBuilder(this)

  buildOneWayBinding: -> new OneWayBindingBuilder(bindingConstructor: Binding)

  buildCompositeSource: -> new CompositeSourceBuilder()

  bind: (binding) -> binding.bind()
