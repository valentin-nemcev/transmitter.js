'use strict'


Variable = require '../nodes/variable'
Transmitter = require '../transmitter'


module.exports = class CheckboxStateVar extends Variable

    constructor: (@element) ->
      @element.addEventListener 'click', =>
        Transmitter.startTransmission (tr) =>
          @originate(tr)

    set: (value) -> @element.checked = value; this

    get: -> @element.checked
