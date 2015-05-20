'use strict'


StatefulNode = require '../nodes/stateful_node'
Transmitter = require '../transmitter'


module.exports = class CheckboxStateVar extends StatefulNode

    constructor: (@element) ->
      @element.addEventListener 'click', =>
        Transmitter.startTransmission (tr) =>
          @originate(tr)

    setValue: (value) -> @element.checked = value; this

    get: -> @element.checked
