'use strict'


Variable = require '../nodes/variable'
Transmitter = require '../transmitter'


module.exports = class InputValueVar extends Variable

  constructor: (@element) ->
    @element.addEventListener 'input', =>
      Transmitter.startTransmission (tr) =>
        @originate(tr)

  setValue: (value) -> @element.value = value; this

  get: -> @element.value
