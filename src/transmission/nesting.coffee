'use strict'


Map = require 'collections/map'


module.exports = class Nesting

  inspect: -> @level

  @createInitial = -> new Nesting(0)

  @merge = (nestings) ->
    new Nesting(Math.max((nestings.map (n) -> n.level)...))


  @getIndependent = (nestings) ->
    independent = new Map()
    for nesting in nestings
      independent.set(nesting.root, nesting)
    return independent.values()


  @equalize = (nestings) ->
    nestings = @getIndependent(nestings)
    maxLevel = Math.max (level for {level} in nestings)...
    nesting.shiftTo(maxLevel) for nesting in nestings
    for i in [1...nestings.length]
      nestings[0].merge(nestings[i])
    return null


  constructor: (@level) ->
    @root = this
    @connected = [this]


  _getConnected: -> @root.connected


  merge: (other) ->
    @add(nesting) for nesting in other._getConnected()
    return this


  add: (other) ->
    other.root = this.root
    @_getConnected().push(other)
    return this


  compare: (other) ->
    this.level - other.level


  shiftTo: (level) ->
    @_shiftBy(level - @level)


  _shiftBy: (levelDiff) ->
    @_getConnected().forEach (nesting) ->
      nesting.level += levelDiff
    return this


  findByLevel = (nestings, level) ->
    return nested for nested in nestings when nestings.level == level
    return null


  _change: (levelDiff) ->
    nesting = findByLevel(@_getConnected(), @level + levelDiff)
    unless nesting?
      nesting = new @constructor(@level + levelDiff)
      @add(nesting)
    return nesting


  increase: -> @_change(+1)

  decrease: -> @_change(-1)
