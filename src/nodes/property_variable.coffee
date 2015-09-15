'use strict'


Variable = require './variable'


module.exports = class PropertyVariable extends Variable


  constructor: (@object, @key) ->

  set: (value) ->
    @object[@key] = value
    this

  get: -> @object[@key]
