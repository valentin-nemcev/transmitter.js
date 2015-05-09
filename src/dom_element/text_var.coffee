'use strict'


StatefulNode = require '../nodes/stateful_node'


module.exports = class TextVar extends StatefulNode

    constructor: (@element) ->

    setValue: (value) -> @element.textContent = value; this

    get: -> @element.textContent
