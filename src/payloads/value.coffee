'use strict'


{inspect} = require 'util'


class ConstValue

  constructor: (@value) ->

  get: -> @value



class ValueUpdatePayload

  constructor: (@source, opts = {}) ->
    @updateFn = opts.update


  deliver: (targetNode) ->
    value = @updateFn.call(null, @source.get(), targetNode.get())
    targetNode.setValue(value)
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


  inspect: -> "state: #{inspect @source}"


  get: ->
    if (value = @source.get())?
      @mapFn.call(null, value)
    else
      @ifEmptyFn.call(null)


  map: (map) ->
    new ValuePayload(this, {map})


  ifEmpty: (ifEmpty) ->
    new ValuePayload(this, {ifEmpty})


  update: (update) ->
    new ValueUpdatePayload(this, {update})


  flatMap: (map) ->
    @map (value) -> map(value).get()


  deliverToTargetNode: (targetNode) ->
    targetNode.receiveValue(@get())
    return this


  deliver: (targetNode) ->
    targetNode.setValue(@get())
    return this
