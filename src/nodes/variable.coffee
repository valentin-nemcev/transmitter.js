'use strict'


StatefulNode = require './stateful_node'


module.exports = class Variable extends StatefulNode

    setValue: (@value) -> this

    get: -> @value
