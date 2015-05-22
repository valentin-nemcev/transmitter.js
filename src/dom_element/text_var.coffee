'use strict'


Variable = require '../nodes/variable'


module.exports = class TextVar extends Variable

  constructor: (@element) ->

  setValue: (value) -> @element.textContent = value; this

  get: -> @element.textContent
