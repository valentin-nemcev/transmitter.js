'use strict'


assert = require 'assert'


class exports.ValuePayload

  @create = (value) => new this(value)

  constructor: (@value) ->


  toState: ->
    new exports.StatePayload(this)


  getValue: ->
    @value


  mapValue: (map) ->
    new exports.ValuePayload(map(@value))


  replaceWhenPresent: (payload) ->
    if @value?
      payload
    else
      this


  deliver: (targetNode) ->
    targetNode.receiveValue(@value)
    return this



class exports.StatePayload

  @create = (node) =>
    return new this(node)


  @createFromValue = (value) =>
    return new this(getValue: -> value)


  constructor: (@node, @update) ->


  toValue: ->
    new exports.ValuePayload(@getValue())


  getValue: ->
    @node.getValue()


  mapValue: (map) ->
    new exports.StatePayload(@node, map)


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


  set: (key, payload) ->
    @payloads.set(key, payload)
    return this


  get: (key) ->
    @payloads.get(key)


  isPresent: ->
    @keys.every (key) => @payloads.get(key)?
