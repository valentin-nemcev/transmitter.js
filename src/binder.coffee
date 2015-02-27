'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
TwoWayBindingBuilder = require './two_way/binding_builder'
Binding = require './binding'

Message = require './message'
MessageChain = require './message/chain'
MessageSender = require './message/sender'
MessageReceiver = require './message/receiver'


module.exports = new class Binder

  sendValue: (value, from: node) ->
    @send(Message.createValue(value), from: node)


  sendBare: (from: node) ->
    @send(Message.createBare(), from: node)


  send: (message, from: node) ->
    chain = new MessageChain()
    message.setChain(chain).sendFrom(node.getMessageSender())
    return this


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
