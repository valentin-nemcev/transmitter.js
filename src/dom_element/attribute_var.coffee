'use strict'


RelayNode = require '../nodes/relay_node'


module.exports = class TextVar extends RelayNode

    constructor: (@element, @attributeName) ->

    setValue: (value) -> @element[@attributeName] = value; this

    get: -> @element[@attributeName]
