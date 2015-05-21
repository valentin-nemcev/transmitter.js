'use strict'


RelayNode = require '../nodes/relay_node'
Transmitter = require '../transmitter'


module.exports = class CheckboxStateVar extends RelayNode

    constructor: (@element) ->
      @element.addEventListener 'click', =>
        Transmitter.startTransmission (tr) =>
          @originate(tr)

    setValue: (value) -> @element.checked = value; this

    get: -> @element.checked
