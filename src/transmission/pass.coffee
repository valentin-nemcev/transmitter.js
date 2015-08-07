'use strict'


{inspect} = require 'util'

directions = require '../directions'


module.exports = class Pass

  inspect: -> 'P:' + @priority + ' ' + @direction.inspect()


  @getForward = -> @forwardPass ?= new Pass(directions.forward, 1)

  @getBackward = -> @backwardPass ?= new Pass(directions.backward, 0)

  @createQueryDefault = -> @getForward()

  @createMessageDefault = -> @getBackward()


  constructor: (@direction, @priority) ->


  directionMatches: (direction) -> @direction.matches(direction)


  equals: (other) ->
    this.direction == other.direction and this.priority == other.priority


  compare: (other) ->
    this.priority - other.priority


  getNext: ->
    if @priority == 1
      null
    else
      @constructor.getForward()


  getForResponse: -> @getNext()
