'use strict'


Variable = require '../nodes/variable'
Transmission = require '../transmission/transmission'


module.exports = class CheckboxStateVar extends Variable

    constructor: (@element) ->
      @element.addEventListener 'click', =>
        Transmission.start (tr) =>
          @originate(tr)

    set: (value) -> @element.checked = value; this

    get: -> @element.checked
