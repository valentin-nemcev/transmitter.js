'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
TwoWayBindingBuilder = require './two_way/binding_builder'
Binding = require './binding'

QueryQueue = require './query_queue'

Query = require './query'

Message = require './message'
{EventPayload, ValuePayload} = require './message/payloads'

MessageChain = require './message/chain'
MessageSender = require './message/sender'
MessageReceiver = require './message/receiver'


module.exports = new class Binder


  startTransmission: (doWithChain) ->
    queryQueue = new QueryQueue()
    chain = new MessageChain({queryQueue})
    doWithChain(chain)
    return this


  startTransmissionWithPayloadFrom: (payload, node) ->
    @startTransmission (chain) =>
      message = new Message(chain)
      message.setPayload(payload)
      message.sendFrom(node.getMessageSender())


  enquire: (node) ->
    @startTransmission (chain) =>
      query = new Query(chain)
      query.enquireTarget(node)


  sendValue: (value, from: node) ->
    @startTransmissionWithPayloadFrom(new ValuePayload(value), node)


  # TODO rename to sendEvent
  sendBare: (from: node) ->
    @startTransmissionWithPayloadFrom(new EventPayload(), node)


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
