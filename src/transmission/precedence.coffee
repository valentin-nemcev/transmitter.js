'use strict'


{inspect} = require 'util'

directions = require '../directions'


module.exports = class Precedence

  inspect: -> 'P:' + @level + ' ' + @direction.inspect()


  @createQueryDefault = -> new Precedence(directions.forward, 1)

  @createMessageDefault = -> new Precedence(directions.backward, 0)


  constructor: (@direction, @level) ->


  directionMatches: (direction) -> @direction.matches(direction)


  equals: (other) ->
    this.direction == other.direction and this.level == other.level


  @merge = (precedences) ->
    if precedences.every((precedence) -> precedence.equals(precedences[0]))
      precedences[0]
    else
      null


  getPrevious: ->
    this


  getFinal: ->
    intLevel = Math.ceil(@level)
    if intLevel == 1
      null
    else
      new Precedence(@direction.reverse(), 1)
