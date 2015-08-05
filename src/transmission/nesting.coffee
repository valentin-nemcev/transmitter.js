'use strict'


{inspect} = require 'util'


module.exports = class Nesting

  @createInitial = -> new Nesting(0)

  @merge = (nestings) ->
    new Nesting(Math.max(nestings.map (n) -> n.level))

  constructor: (@level) ->

  compare: (other) ->
    this.level - other.level

  increase: ->
    new @constructor(@level + 1)

  decrease: ->
    new @constructor(@level - 1)
