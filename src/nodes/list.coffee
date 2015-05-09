'use strict'


StatefulNode = require './stateful_node'


module.exports = class Variable extends StatefulNode

    constructor: ->
      @list = []


    setValue: (list) ->
      @list.length = 0
      @list.push list...
      this


    get: ->
      @list.slice()
