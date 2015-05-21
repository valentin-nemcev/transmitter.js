'use strict'


RelayNode = require '../nodes/relay_node'
Transmitter = require '../transmitter'


module.exports = class InputValueVar extends RelayNode

  constructor: (@element) ->
    @element.addEventListener 'input', =>
      Transmitter.startTransmission (tr) =>
        @originate(tr)

  setValue: (value) -> @element.value = value; this

  get: -> @element.value
