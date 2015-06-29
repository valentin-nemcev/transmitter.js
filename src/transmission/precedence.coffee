'use strict'


directions = require '../directions'


module.exports = class Precedence

  inspect: -> 'P:' + @level + ' ' + @direction.inspect()


  @createQueryDefault = -> new Precedence(directions.forward, 1)

  @createMessageDefault = -> new Precedence(directions.backward, 0)


  constructor: (@direction, @level) ->


  directionMatches: (direction) -> @direction.matches(direction)


  @merge = (precedences) ->
    direction = precedences[0].direction
    level = 0
    level += p.level for p in precedences
    level /= precedences.length

    new Precedence(direction, level)


  getPrevious: ->
    intLevel = Math.ceil(@level)
    if intLevel == 0
      new Precedence(@direction, -1)
    else
      this


  getFinal: ->
    intLevel = Math.ceil(@level)
    if intLevel == 1
      null
    else
      new Precedence(@direction.reverse(), 1)
