'use strict'


Transmission = require './transmission/transmission'


module.exports = new class Transmitter

  Nodes:        require './nodes'
  Payloads:     require './payloads'
  Channels:     require './channels'
  ChannelNodes: require './channel_nodes'
  DOMElement:   require './dom_element'
  Transmission: Transmission

  constructor: (opts = {}) ->


  setLogging: (state) ->
    Transmission::loggingIsEnabled = state
    return this


  withDifferentTransmissionOrders: (doWithOrder) ->
    for order in ['straight', 'reverse']
      doWithOrder(order)
    return this


  startTransmissionWithLogging: (doWithTransmission) ->
    @setLogging on
    @startTransmission(doWithTransmission)
    @setLogging off

  startTransmission: (doWithTransmission) ->
    Transmission.start(doWithTransmission)
    return this
