'use strict'


SourceNode = require '../nodes/source_node'
Transmitter = require '../transmitter'


module.exports = class DOMEvent extends SourceNode

  constructor: (@element, @type) ->
    @element.addEventListener @type, @triggerEvent

  triggerEvent: (ev) =>
    Transmitter.startTransmission (tr) =>
      @originate(ev, tr)
