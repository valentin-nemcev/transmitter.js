'use strict'


StatefulNode = require '../nodes/stateful_node'
Transmitter = require '../transmitter'


module.exports = class CheckboxStateVar extends StatefulNode

    constructor: (@element) ->
      @element.addEventListener 'click', @triggerUpdate

    triggerUpdate: => Transmitter.originate(this)

    setValue: (value) -> @element.checked = value; this

    get: -> @element.checked
