'use strict'


EventSource = require '../nodes/event_source'
Transmitter = require '../transmitter'


module.exports = class DOMEvent extends EventSource

  constructor: (@element, @type) ->
    @element.addEventListener @type, @triggerEvent

  triggerEvent: (ev) =>
    Transmitter.startTransmission (tr) =>
      @originate(ev, tr)
