'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
TwoWayBindingBuilder = require './two_way/binding_builder'
Binding = require './binding'

Query = require './query'

Message = require './message'
{EventPayload, ValuePayload, StatePayload} = require './message/payloads'

MessageChain = require './message/chain'
MessageSender = require './message/sender'
MessageReceiver = require './message/receiver'


module.exports = new class Binder


  createQueryResponseMessage: (messageChain, node) ->
    message = new Message(messageChain)
    message.setPayload(new StatePayload(node))
    return message


  startTransmission: (doWithChain) ->
    messageChain = new MessageChain()
    doWithChain(messageChain)
    for node in messageChain.getEnqueriedNodes()
      message = new Message(messageChain)
      payload = new StatePayload(node)
      message.setPayload(payload)
      message.sendFrom(node.getMessageSender())

    return this


  startTransmissionWithPayloadFrom: (payload, node) ->
    @startTransmission (messageChain) =>
      message = new Message(messageChain)
      message.setPayload(payload)
      message.sendFrom(node.getMessageSender())


  enquire: (node) ->
    @startTransmission (messageChain) =>
      query = new Query({messageChain})
      query.enquireTargetNode(node)


  updateNodeState: (node, value) ->
    payload = StatePayload.updateNodeAndCreate(node, value)
    @startTransmissionWithPayloadFrom(payload, node)


  sendNodeState: (node) ->
    @startTransmissionWithPayloadFrom(new StatePayload(node), node)


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
