'use strict'


Variable = require '../nodes/variable'


module.exports = class TextVar extends Variable

  constructor: (@element) ->

  set: (value) -> @element.textContent = value; this

  get: -> @element.textContent
