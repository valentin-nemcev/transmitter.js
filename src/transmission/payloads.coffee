'use strict'


assert = require 'assert'
{inspect} = require 'util'


class exports.ValuePayload

  @create = (value) => new this(value)

  constructor: (@value) ->


  inspect: -> "value: #{inspect @value}"


  toState: ->
    new exports.StatePayload(this)


  getValue: ->
    @value


  mapValue: (map) ->
    new exports.ValuePayload(map(@value))


  map: -> @mapValue(arguments...)


  replaceWhenPresent: (payload) ->
    if @value?
      payload
    else
      this


  deliver: (targetNode) ->
    targetNode.receiveValue(@value)
    return this



class exports.ListPayload

  constructor: (@list) ->


  inspect: -> "list: #{inspect @value}"


  map: (map) ->
    return new exports.ListPayload(@list.map(map))


  deliver: (targetNode) ->
    targetNode.setValue(@list)
    return this



class exports.StatePayload

  @create = (node) =>
    return new this(node)


  @createFromValue = (value) =>
    return new this(getValue: -> value)


  constructor: (@node, @update) ->


  inspect: -> "state: #{inspect @node}"


  toValue: ->
    new exports.ValuePayload(@getValue())


  getValue: ->
    @node.getValue()


  mapValue: (map) ->
    new exports.StatePayload(@node, map)


  map: -> @mapValue(arguments...)


  deliver: (targetNode) ->
    value = if @update?
      @update(@getValue(), targetNode.getValue())
    else
      @getValue()
    targetNode.setValue(value)
    return this



class exports.MergedPayload

  constructor: (@keys) ->
    @payloads = new Map()


  deliver: ->
    assert(false, "Can't deliver MergedPayload")


  reduceValue: (initial, reduce) ->
    result = initial
    for [node, payload] in Array.from(@payloads.entries())
      result = reduce(result, node, payload.getValue())
    new exports.ValuePayload(result)


  fetch: (struct) ->
    new exports.StructPayload(struct).map (key) => @payloads.get(key)


  replaceWithValue: (value) ->
    new exports.ValuePayload(value)


  set: (key, payload) ->
    @payloads.set(key, payload)
    return this


  get: (key) ->
    @payloads.get(key)


  isPresent: ->
    @keys.every (key) => @payloads.get(key)?



class exports.StructPayload

  constructor: (struct = {}) ->
    this[key] = val for own key, val of struct


  map: (map) ->
    result = new @constructor()
    result[key] = map(val, key) for own key, val of this
    return result


  zip: ->
    result = []
    for own key, val of this
      for el, i in val.getValue()
        result[i] ?= new @constructor()
        result[i][key] = el

    return new exports.ListPayload(result)



class exports.ConnectionPayload

  @createConnect = (origin) -> new this(origin)


  constructor: (@origin) ->


  inspect: -> "connect (#{inspect @origin})"


  deliver: (line) ->
    line.setOrigin(@origin)
    line.connect()
    return this
