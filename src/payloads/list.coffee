'use strict'


{inspect} = require 'util'


class SetConstPayload

  @create = (value) => new this(value)

  constructor: (@value) ->

  inspect: -> "setConst(#{inspect @value})"
  inspect: -> "setConst()"

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



class RemovePayload

  @create = (@source) => new this(@source)

  constructor: (@source) ->

  inspect: -> "listRemove(#{inspect @source})"

  deliverToList: (target) ->
    element = @source.get()
    for el, pos in target.get() when el == element
      target.removeAt(pos)
    return this


class AddAtPayload

  @create = (@source) => new this(@source)

  constructor: (@source) ->

  inspect: -> "listAddAt(#{inspect @source.get()})"

  deliverToList: (target) ->
    target.addAt(@source.get()...)
    return this


class UpdateMatchingPayload

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



class SetPayload

  @create = (source) =>
    return new this(source)


  id = (a) -> a

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id


  inspect: -> "list(#{inspect @get()})"


  get: ->
    @mapFn.call(null, el) for el in @source.get()


  getAt: (pos) ->
    @mapFn.call(null, @source.getAt(pos))


  getSize: ->
    @source.getSize()


  map: (map) ->
    new SetPayload(this, {map})


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



module.exports = {
  set: SetPayload.create
  setLazy: (getValue) -> SetPayload.create(get: getValue)
  setConst: SetConstPayload.create
  append: (elementSource) ->
    AddAtPayload.create(elementSource.map (el) -> [el, null])
  appendConst: (element) ->
    AddAtPayload.create(get: -> [element, null])
  removeConst: (element) ->
    RemovePayload.create(get: -> element)
}
