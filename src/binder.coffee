'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
TwoWayBindingBuilder = require './complex_bindings/two_way_binding_builder'
Binding = require './binding/binding'

Query = require './transmission/query'

Message = require './transmission/message'
{EventPayload, ValuePayload, StatePayload} = require './transmission/payloads'

MessageChain = require './transmission/chain'
NodeSource = require './binding/node_source'
NodeTarget = require './binding/node_target'


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
      message.sendFrom(node)

    return this


  startTransmissionWithPayloadFrom: (payload, node) ->
    @startTransmission (messageChain) =>
      message = new Message(messageChain)
      message.setPayload(payload)
      message.sendFrom(node)


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
    NodeSource.extend(cls)
    return this


  extendWithMessageReceiver: (cls) ->
    NodeTarget.extend(cls)
    return this


  buildTwoWayBinding: -> new TwoWayBindingBuilder(this)

  buildOneWayBinding: -> new OneWayBindingBuilder(bindingConstructor: Binding)

  buildCompositeSource: -> new CompositeSourceBuilder()

  bind: (binding) -> binding.bind()
