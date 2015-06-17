'use strict'


{inspect} = require 'util'


class ConstValue

  constructor: (@value) ->

  get: -> @value


id = (a) -> a
getNull = -> null


class ValueUpdatePayload

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @matchFn = opts.match
    @ifEmptyFn = opts.ifEmpty ? getNull


  inspect: -> "valueUpdate(#{inspect @source})"


  deliverValueState: (target) ->
    sourceValue = @source.get()
    targetValue = target.get()
    return this if sourceValue? and targetValue? \
      and @matchFn.call(null, sourceValue, targetValue)

    newTargetValue = if sourceValue?
      @mapFn.call(null, sourceValue)
    else
      @ifEmptyFn.call(null)
    target.set(newTargetValue)
    return this



module.exports = class ValuePayload

  @create = (source) =>
    return new this(source)


  @createFromValue = (value) =>
    return new this(new ConstValue(value))


  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @ifEmptyFn = opts.ifEmpty ? getNull


  inspect: -> "value(#{inspect @get()})"


  get: ->
    if (value = @source.get())?
      @mapFn.call(null, value)
    else
      @ifEmptyFn.call(null)


  map: (map) ->
    new ValuePayload(this, {map})


  ifEmpty: (ifEmpty) ->
    new ValuePayload(this, {ifEmpty})


  mapIfMatch: (map, match, ifEmpty) ->
    new ValueUpdatePayload(this, {map, match, ifEmpty})


  flatMap: (map) ->
    @map (value) -> map(value).get()


  deliverValue: (targetNode) ->
    targetNode.receiveValue(@get())
    return this


  deliverValueState: (targetNode) ->
    targetNode.set(@get())
    return this
