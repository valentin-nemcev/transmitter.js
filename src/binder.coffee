'use strict'


CompositeSourceBuilder = require './binding/composite_source_builder'
OneWayBindingBuilder = require './binding/one_way_builder'
TwoWayBindingBuilder = require './complex_bindings/two_way_binding_builder'

Query = require './transmission/query'

{EventPayload, ValuePayload, StatePayload} = require './transmission/payloads'

Transmission = require './transmission/transmission'
NodeSource = require './binding/node_source'
NodeTarget = require './binding/node_target'


module.exports = new class Binder


  createQueryResponseMessage: (transmission, node) ->
    message = new Message(transmission)
    message.setPayload(new StatePayload(node))
    return message


  startTransmission: (doWithTransmission) ->
    transmission = new Transmission()
    doWithTransmission(transmission)
    for node in transmission.getEnqueriedNodes()
      payload = new StatePayload(node)
      message = transmission.createMessage(payload)
      message.sendFromNode(node)

    return this


  startTransmissionWithPayloadFrom: (payload, node) ->
    @startTransmission (transmission) =>
      message = transmission.createMessage(payload)
      message.sendFromNode(node)


  enquire: (node) ->
    @startTransmission (transmission) =>
      query = new Query({transmission})
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


  extendWithNodeSource: (cls) ->
    NodeSource.extend(cls)
    return this


  extendWithNodeTarget: (cls) ->
    NodeTarget.extend(cls)
    return this


  buildTwoWayBinding: -> new TwoWayBindingBuilder(this)

  buildOneWayBinding: -> new OneWayBindingBuilder()

  buildCompositeSource: -> new CompositeSourceBuilder()

  bind: (binding) -> binding.bind()
