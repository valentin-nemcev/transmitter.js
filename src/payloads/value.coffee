'use strict'


{inspect} = require 'util'


class ConstValue

  constructor: (@value) ->

  get: -> @value



class ValueUpdatePayload

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map
    @matchFn = opts.match


  inspect: -> "valueUpdate(#{inspect @source})"


  deliverValueState: (target) ->
    sourceValue = @source.get()
    targetValue = target.get()
    unless sourceValue? and targetValue? \
      and @matchFn.call(null, sourceValue, targetValue)
        target.set(@mapFn.call(null, sourceValue))
    return this



module.exports = class ValuePayload

  @create = (source) =>
    return new this(source)


  @createFromValue = (value) =>
    return new this(new ConstValue(value))


  id = (a) -> a

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @ifEmptyFn = opts.ifEmpty ? -> null


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


  mapIfMatch: (map, match) ->
    new ValueUpdatePayload(this, {map, match})


  flatMap: (map) ->
    @map (value) -> map(value).get()


  deliverValue: (targetNode) ->
    targetNode.receiveValue(@get())
    return this


  deliverValueState: (targetNode) ->
    targetNode.set(@get())
    return this
