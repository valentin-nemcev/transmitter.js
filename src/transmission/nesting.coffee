'use strict'


{inspect} = require 'util'

Set = require 'collections/set'


module.exports = class Nesting

  inspect: -> @level
    # "#{@level} -> [#{@nested.map(inspect).join(', ')}]"

  @createInitial = -> new Nesting(0)

  @merge = (nestings) ->
    new Nesting(Math.max((nestings.map (n) -> n.level)...))


  getIndependent = (nestings) ->
    independent = []
    nestings.forEach (nesting) ->
      unless nestings.some((n) -> n.contains(nesting))
        independent.push nesting
    return independent

  @equalize = (nestings) ->
    nestings = getIndependent(nestings)
    maxLevel = Math.max (level for {level} in nestings)...
    nesting.shiftTo(maxLevel) for nesting in nestings
    return null


  constructor: (@level) ->
    @nested = new Set()


  addNested: (other) ->
    @nested.add other
    return this


  contains: (other) ->
    @nested.has(other)


  compare: (other) ->
    this.level - other.level


  shiftTo: (level) ->
    @shiftBy(level - @level)


  shiftBy: (levelDiff) ->
    @level += levelDiff
    @nested.forEach (nesting) -> nesting.shiftBy(levelDiff)
    return this


  increase: ->
    nested = new @constructor(@level + 1)
    @addNested(nested)
    return nested


  decrease: ->
    new @constructor(@level - 1).addNested(this)
