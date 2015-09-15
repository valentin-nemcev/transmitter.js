'use strict'


SourceNode = require '../nodes/source_node'
Transmission = require '../transmission/transmission'


module.exports = class DOMEvent extends SourceNode

  constructor: (@element, @type) ->
    @element.addEventListener @type, @triggerEvent

  triggerEvent: (ev) =>
    Transmission.start (tr) =>
      @originate(tr, ev)
