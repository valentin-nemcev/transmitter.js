'use strict'


StatefulNode = require '../nodes/stateful_node'


module.exports = class TextVar extends StatefulNode

    constructor: (@element, @attributeName) ->

    setValue: (value) -> @element[@attributeName] = value; this

    getValue: -> @element[@attributeName]
