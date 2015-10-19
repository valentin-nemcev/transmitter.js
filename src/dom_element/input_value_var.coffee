'use strict'


Variable = require '../nodes/variable'
Transmission = require '../transmission/transmission'


module.exports = class InputValueVar extends Variable

  constructor: (@element) ->
    @element.addEventListener 'change', =>
      Transmission.start (tr) =>
        @originate(tr)

  set: (value) -> @element.value = value; this

  get: -> @element.value
