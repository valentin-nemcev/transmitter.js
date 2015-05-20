'use strict'


StatefulNode = require '../nodes/stateful_node'
Transmitter = require '../transmitter'


module.exports = class InputValueVar extends StatefulNode

  constructor: (@element) ->
    @element.addEventListener 'input', =>
      Transmitter.startTransmission (tr) =>
        @originate(tr)

  setValue: (value) -> @element.value = value; this

  get: -> @element.value
