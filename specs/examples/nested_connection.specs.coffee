'use strict'


Transmitter = require 'transmitter'


class VariableNode

  Transmitter.extendWithStatefulNode(this)

  getValue: -> @value

  setValue: (@value) -> this


describe 'Nested connection', ->

  # specify '.'
