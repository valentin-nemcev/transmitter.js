'use strict'


RelayNode = require './relay_node'


module.exports = class Variable extends RelayNode

    setValue: (@value) -> this

    get: -> @value
