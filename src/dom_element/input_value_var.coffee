'use strict'


StatefulNode = require '../nodes/stateful_node'
Transmitter = require '../transmitter'


module.exports = class InputValueVar extends StatefulNode

    constructor: (@element) ->
      @element.addEventListener 'input', @triggerUpdate

    triggerUpdate: => Transmitter.originate(this)

    setValue: (value) -> @element.value = value; this

    getValue: -> @element.value
