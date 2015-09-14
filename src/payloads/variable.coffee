'use strict'


{inspect} = require 'util'


class SetConstPayload

  @create = (value) => new this(value)

  constructor: (@value) ->

  setPriority: (@priority) -> this

  getPriority: -> @priority ? 1

  inspect: -> "#{@getPriority()}:setConst(#{inspect @value})"

  map: (map) ->
    new SetPayload(this, {map})

  get: -> @value

  deliverToVariable: (variable) ->
    variable.set(@value)
    return this


id = (a) -> a
getNull = -> null


class UpdateMatchingPayload

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @matchFn = opts.match


  inspect: -> "#{@getPriority()}:valueUpdate(#{inspect @source})"

  setPriority: (@priority) -> this

  getPriority: -> @priority ? @source.getPriority()


  deliverToVariable: (target) ->
    sourceValue = @source.get()
    targetValue = target.get()
    return this if sourceValue? and targetValue? \
      and @matchFn.call(null, sourceValue, targetValue)

    newTargetValue = if sourceValue?
      @mapFn.call(null, sourceValue)
    else
      null
    target.set(newTargetValue)
    return this



class SetPayload

  @create = (source) =>
    return new this(source)


  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id


  inspect: -> "#{@getPriority()}:value(#{inspect @get()})"


  setPriority: (@priority) -> this

  getPriority: -> @priority ? @source.getPriority()


  get: ->
    @mapFn.call(null, @source.get())


  map: (map) ->
    new SetPayload(this, {map})


  updateMatching: (map, match) ->
    new UpdateMatchingPayload(this, {map, match})


  flatMap: (map) ->
    @map (value) -> map(value).get()


  deliverValue: (targetNode) ->
    targetNode.receiveValue(@get())
    return this


  deliverToVariable: (variable) ->
    variable.set(@get())
    return this



module.exports = {
  set: SetPayload.create
  setLazy: (getValue) -> SetPayload.create(get: getValue).setPriority(1)
  setConst: (value) -> SetConstPayload.create(value).setPriority(1)
}
