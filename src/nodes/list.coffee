'use strict'


RelayNode = require './relay_node'


module.exports = class Variable extends RelayNode

    constructor: ->
      @list = []


    setValue: (list) ->
      @list.length = 0
      @list.push list...
      this


    get: ->
      @list.slice()
