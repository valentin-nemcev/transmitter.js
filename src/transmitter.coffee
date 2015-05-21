'use strict'


Transmission = require './transmission/transmission'


module.exports = new class Transmitter

  Nodes:        require './nodes'
  Channels:     require './channels'
  ChannelNodes: require './channel_nodes'
  DOMElement:   require './dom_element'

  constructor: (opts = {}) ->
    {@reverseOrder} = opts


  withLogging: (state, doWithLogging) ->
    if arguments.length is 1
      [state, doWithLogging] = [yes, state]
    Transmission::loggingIsEnabled = state
    doWithLogging()
    Transmission::loggingIsEnabled = no
    return this


  withDifferentTransmissionOrders: (doWithOrder) ->
    doWithOrder(new @constructor(reverseOrder: no), 'straight')
    doWithOrder(new @constructor(reverseOrder: yes), 'reverse')
    return this



  startTransmission: (doWithTransmission) ->
    Transmission::reverseOrder = @reverseOrder
    Transmission.start(doWithTransmission)
    return this
