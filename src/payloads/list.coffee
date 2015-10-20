'use strict'


{inspect} = require 'util'

noop = require './noop'
VariablePayload = require './variable'
Payload = require './payload'


zip = (payloads, coerceSize = no) ->
  SetPayload.create get: ->
    length = payloads[0]?.getSize() ? 0
    unless coerceSize
      for p in payloads when p.getSize() != length
        throw new Error "Can't zip lists with different sizes: " + \
                          payloads.map(inspect).join(', ')
    for i in [0...length]
      for p in payloads
        p.getAt(i)


class ListPayload extends Payload

  flatten: ->
    @map (nested) -> nested.get()

  unflatten: ->
    @map (value) -> VariablePayload.setConst(value)

  zipCoercingSize: (otherPayloads...) -> zip([this, otherPayloads...], true)

  zip: (otherPayloads...) -> zip([this, otherPayloads...])

  setSize: (size) ->
    SetLazyPayload.create =>
      @getAt(i) for i in [0...size]



class SetConstPayload extends ListPayload

  @create = (value) => new this(value)

  constructor: (@value) ->

  inspect: -> "setConst(#{inspect @value})"

  map: (map) ->
    new SetPayload(this, {map})

  filter: (filter) ->
    new SetPayload(this, {filter})

  updateMatching: (map, match) ->
    new UpdateMatchingPayload(this, {map, match})

  get: -> @value

  getAt: (pos) ->
    @value[pos]

  getSize: -> @value.length


  deliverToVariable: (variable) ->
    variable.set(@get())
    return this


  deliverToList: (list) ->
    list.set(@get())
    return this



class SetLazyPayload extends ListPayload

  @create = (getValue) => new this(getValue)

  constructor: (@getValue) ->

  inspect: -> "setLazy(#{inspect @getValue()})"

  map: (map) ->
    new SetPayload(this, {map})

  filter: (filter) ->
    new SetPayload(this, {filter})

  updateMatching: (map, match) ->
    new UpdateMatchingPayload(this, {map, match})

  get: -> @value ?= @getValue()

  getAt: (pos) ->
    @get()[pos]

  getSize: -> @get().length


  deliverToVariable: (variable) ->
    variable.set(@get())
    return this


  deliverToList: (list) ->
    list.set(@get())
    return this



class RemovePayload extends ListPayload

  @create = (@source) => new this(@source)

  constructor: (@source) ->

  inspect: -> "listRemove(#{inspect @source})"

  deliverToList: (target) ->
    element = @source.get()
    for el, pos in target.get() when el == element
      target.removeAt(pos)
    return this


class AddAtPayload extends ListPayload

  @create = (@source) => new this(@source)

  constructor: (@source) ->

  inspect: -> "listAddAt(#{inspect @source.get()})"

  deliverToList: (target) ->
    target.addAt(@source.get()...)
    return this


class UpdateMatchingPayload extends ListPayload

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map
    @matchFn = opts.match

  inspect: -> "listUpdate(#{inspect @source})"


  deliverToList: (target) ->
    targetLength = target.getSize()
    sourceLength = @source.getSize()

    targetPos = sourcePos = 0
    loop
      if sourcePos < sourceLength
        sourceEl = @source.getAt(sourcePos)

        sourcePosInTarget = targetPos
        while sourcePosInTarget < targetLength
          targetElAtSourcePos = target.getAt(sourcePosInTarget)
          break if @matchFn.call(null, sourceEl, targetElAtSourcePos)
          sourcePosInTarget++

        if sourcePosInTarget < targetLength # Target contains source element
          if sourcePosInTarget != targetPos
            target.move(sourcePosInTarget, targetPos)
          targetPos++
        else
          target.addAt(@mapFn.call(null, sourceEl), targetPos)
          targetLength++
          targetPos++

        sourcePos++

      else if sourceLength <= sourcePos and targetPos < targetLength
        if true # target.shouldRemoveAt(targetPos)
          target.removeAt(targetPos)
          targetLength--
        else
          targetPos++

      else
        break

    return this



class SetPayload extends ListPayload

  @create = (source) =>
    return new this(source)


  id = (a) -> a
  getTrue = -> true

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @filterFn = opts.filter ? getTrue


  inspect: -> "list(#{inspect @get()})"


  get: ->
    @result ?= for el in @source.get() when @filterFn.call(null, el)
      @mapFn.call(null, el)


  getAt: (pos) ->
    @get()[pos]


  getSize: ->
    @get().length


  map: (map) ->
    new SetPayload(this, {map})


  filter: (filter) ->
    new SetPayload(this, {filter})


  updateMatching: (map, match) ->
    new UpdateMatchingPayload(this, {map, match})


  deliverValue: (targetNode) ->
    targetNode.receiveValue(@get())
    return this


  deliverToVariable: (variable) ->
    variable.set(@get())
    return this


  deliverToList: (list) ->
    list.set(@get())
    return this


NoopPayload = noop().constructor

Payload::toSetList = -> SetPayload.create(this)
NoopPayload::toSetList = -> this

Payload::toAppendListElement = -> AddAtPayload.create(this.map (el) -> [el, null])
NoopPayload::toAppendListElement = -> this

Payload::toRemoveListElement = -> RemovePayload.create(this)
NoopPayload::toRemoveListElement = -> this

module.exports = {
  set: SetPayload.create
  setLazy: (getValue) -> SetLazyPayload.create(getValue)
  setConst: SetConstPayload.create
  append: (elementSource) ->
    AddAtPayload.create(elementSource.map (el) -> [el, null])
  appendConst: (element) ->
    AddAtPayload.create(get: -> [element, null])
  removeConst: (element) ->
    RemovePayload.create(get: -> element)
}
