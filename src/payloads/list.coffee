'use strict'


{inspect} = require 'util'


class ConstValue

  constructor: (@value) ->

  get: -> @value

  getAt: (pos) ->
    @value[pos]

  getSize: -> @value.length



class ListNoOpPayload

  constructor: ->

  inspect: -> "listNoOp()"

  deliverListState: (target) ->
    return this

  deliverValueState: (target) ->
    return this


class ListRemovePayload

  constructor: (@element) ->

  inspect: -> "listRemove(#{inspect @element})"

  deliverListState: (target) ->
    for el, pos in target.get() when el == @element
      target.removeAt(pos)
    return this


class ListAddAtPayload

  constructor: (@element, @pos) ->

  inspect: -> "listAddAt(#{inspect @element}, #{@pos})"

  deliverListState: (target) ->
    target.addAt(@element, @pos)
    return this


class ListUpdatePayload

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map
    @matchFn = opts.match

  inspect: -> "listUpdate(#{inspect @source})"


  deliverListState: (target) ->
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



module.exports = class ListPayload

  @create = (source) =>
    return new this(source)


  @createFromValue = (value) =>
    return new this(new ConstValue(value))


  @createRemove = (element) =>
    return new ListRemovePayload(element)


  @createAddAt = (element, pos) =>
    return new ListAddAtPayload(element, pos)


  @createNoOp = =>
    return new ListNoOpPayload()


  id = (a) -> a

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @ifEmptyFn = opts.ifEmpty ? -> []


  inspect: -> "list(#{inspect @get()})"


  get: ->
    if (value = @source.get()).length
      @mapFn.call(null, el) for el in value
    else
      @ifEmptyFn.call(null)


  getAt: (pos) ->
    @mapFn.call(null, @source.getAt(pos))


  getSize: ->
    @source.getSize()


  map: (map) ->
    new ListPayload(this, {map})


  ifEmpty: (ifEmpty) ->
    new ListPayload(this, {ifEmpty})


  mapIfMatch: (map, match) ->
    new ListUpdatePayload(this, {map, match})


  deliverValue: (targetNode) ->
    targetNode.receiveValue(@get())
    return this


  deliverValueState: (targetNode) ->
    targetNode.set(@get())
    return this


  deliverListState: (targetNode) ->
    targetNode.set(@get())
    return this
