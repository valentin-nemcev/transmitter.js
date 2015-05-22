'use strict'


Variable = require '../nodes/variable'


module.exports = class TextVar extends Variable

  constructor: (@element, @attributeName) ->

  set: (value) -> @element[@attributeName] = value; this

  get: -> @element[@attributeName]
