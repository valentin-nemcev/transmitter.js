'use strict'


{inspect} = require 'util'

Payload = require './payload'
noop = require './noop'


class VariablePayload extends Payload

  noopIf: (conditionCb) ->
    if conditionCb(@get()) then noop() else this

  merge: (otherPayloads...) ->
    @map (value) => [value, otherPayloads.map((p) -> p.get())...]


  separate: ->
    @get().map (value) ->
      SetConstPayload.create(value)


class SetConstPayload extends VariablePayload

  @create = (value) => new this(value)

  constructor: (@value) ->

  inspect: -> "setConst(#{inspect @value})"

  map: (map) ->
    new SetPayload(this, {map})

  get: -> @value

  deliverToVariable: (variable) ->
    variable.set(@value)
    return this


id = (a) -> a
getNull = -> null


class UpdateMatchingPayload extends VariablePayload

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @matchFn = opts.match


  inspect: -> "valueUpdate(#{inspect @source})"


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



class SetPayload extends VariablePayload

  @create = (source) =>
    return new this(source)


  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id


  inspect: -> "value(#{inspect @get()})"


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



NoopPayload = noop().constructor

Payload::toSetVariable = -> SetPayload.create(this)
NoopPayload::toSetVariable = -> this

module.exports = {
  set: SetPayload.create
  setLazy: (getValue) -> SetPayload.create(get: getValue)
  setConst: (value) -> SetConstPayload.create(value)
}
