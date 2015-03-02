'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
TwoWayBindingBuilder = require './two_way/binding_builder'
Binding = require './binding'

QueryQueue = require './query_queue'

Message = require './message'
MessageChain = require './message/chain'
MessageSender = require './message/sender'
MessageReceiver = require './message/receiver'


module.exports = new class Binder


  startTransmissionWithMessageFrom: (message, node) ->
    queryQueue = new QueryQueue()
    chain = new MessageChain({queryQueue})
    message.setChain(chain)
    node.getMessageSender().send(message)
    return this



  sendValue: (value, from: node) ->
    @startTransmissionWithMessageFrom(Message.createValue(value), node)


  sendBare: (from: node) ->
    @startTransmissionWithMessageFrom(Message.createBare(), node)


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
