'use strict'


{inspect} = require 'util'


class ConstValue

  constructor: (@value) ->

  get: -> @value



module.exports = class ListPayload

  @create = (source) =>
    return new this(source)


  @createFromValue = (value) =>
    return new this(new ConstValue(value))


  id = (a) -> a

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @ifEmptyFn = opts.ifEmpty ? -> []


  inspect: -> "state: #{inspect @source}"


  get: ->
    if (value = @source.get()).length
      value.map(@mapFn)
    else
      @ifEmptyFn.call(null)


  map: (map) ->
    new ListPayload(this, {map})


  ifEmpty: (ifEmpty) ->
    new ListPayload(this, {ifEmpty})


  deliverToTargetNode: (targetNode) ->
    targetNode.receiveValue(@get())
    return this


  deliver: (targetNode) ->
    targetNode.setValue(@get())
    return this
