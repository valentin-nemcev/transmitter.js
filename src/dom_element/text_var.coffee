'use strict'


RelayNode = require '../nodes/relay_node'


module.exports = class TextVar extends RelayNode

    constructor: (@element) ->

    setValue: (value) -> @element.textContent = value; this

    get: -> @element.textContent
