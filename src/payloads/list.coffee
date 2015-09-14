'use strict'


{inspect} = require 'util'


class SetConstPayload

  @create = (value) => new this(value)

  constructor: (@value) ->

  getPriority: -> 1

  inspect: -> "#{@getPriority()}:setConst(#{inspect @value})"

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



class SetLazyPayload

  @create = (getValue) => new this(getValue)

  constructor: (@getValue) ->

  setPriority: (@priority) -> this

  getPriority: -> @priority ? 1


  inspect: -> "#{@getPriority()}:setLazy(#{inspect @getValue()})"

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



class RemovePayload

  @create = (@source) => new this(@source)

  constructor: (@source) ->

  setPriority: (@priority) -> this

  getPriority: -> @priority ? @source.getPriority()

  inspect: -> "#{@getPriority()}:listRemove(#{inspect @source})"

  deliverToList: (target) ->
    element = @source.get()
    for el, pos in target.get() when el == element
      target.removeAt(pos)
    return this


class AddAtPayload

  @create = (@source) => new this(@source)

  constructor: (@source) ->

  setPriority: (@priority) -> this

  getPriority: -> @priority ? @source.getPriority()

  inspect: -> "#{@getPriority()}:listAddAt(#{inspect @source.get()})"

  deliverToList: (target) ->
    target.addAt(@source.get()...)
    return this


class UpdateMatchingPayload

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map
    @matchFn = opts.match

  inspect: -> "#{@getPriority()}:listUpdate(#{inspect @source})"

  setPriority: (@priority) -> this

  getPriority: -> @priority ? @source.getPriority()


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
  getTrue = -> true

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @filterFn = opts.filter ? getTrue


  inspect: -> "#{@getPriority()}:list(#{inspect @get()})"


  setPriority: (@priority) -> this

  getPriority: -> @priority ? @source.getPriority()


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



module.exports = {
  set: SetPayload.create
  setLazy: (getValue) -> SetLazyPayload.create(getValue).setPriority(1)
  setConst: SetConstPayload.create
  append: (elementSource) ->
    AddAtPayload.create(elementSource.map (el) -> [el, null])
  appendConst: (element) ->
    AddAtPayload.create(get: -> [element, null])
  removeConst: (element) ->
    RemovePayload.create(get: -> element)
}
