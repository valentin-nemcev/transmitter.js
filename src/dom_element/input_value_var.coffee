'use strict'


Variable = require '../nodes/variable'
Transmission = require '../transmission/transmission'


module.exports = class InputValueVar extends Variable

  constructor: (@element) ->
    @element.addEventListener 'input', =>
      Transmission.start (tr) =>
        @originate(tr)

  set: (value) -> @element.value = value; this

  get: -> @element.value
