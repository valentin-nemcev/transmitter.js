'use strict'


require 'es6-shim'

Transmission = require './transmission/transmission'


module.exports = new class Transmitter

  Nodes:        require './nodes'
  Channels:     require './channels'
  ChannelNodes: require './channel_nodes'
  DOMElement:   require './dom_element'

  constructor: (opts = {}) ->
    {@reverseOrder} = opts


  setLogging: (state) ->
    Transmission::loggingIsEnabled = state
    return this


  withDifferentTransmissionOrders: (doWithOrder) ->
    doWithOrder(new @constructor(reverseOrder: no), 'straight')
    doWithOrder(new @constructor(reverseOrder: yes), 'reverse')
    return this



  startTransmission: (doWithTransmission) ->
    Transmission::reverseOrder = @reverseOrder
    Transmission.start(doWithTransmission)
    return this
