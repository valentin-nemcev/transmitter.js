'use strict'


assert = require 'assert'


class exports.EventPayload

  @create = => new this(no)

  @createNull = => new this(yes)


  constructor: (@isNull) ->


  toValue: (value) -> new exports.ValuePayload(value)


  replaceWhenPresent: (payload) ->
    if @isNull
      new exports.ValuePayload(null)
    else
      payload


class exports.ValuePayload

  constructor: (@value) ->


  getValue: ->
    @value


  mapValue: (map) ->
    new exports.ValuePayload(map(@value))


  deliver: (targetNode) ->
    if targetNode.setValue? and not targetNode.receiveValue?
      targetNode.setValue(@value)
    else
      targetNode.receiveValue(@value)
    return this



class exports.StatePayload

  @create = (node) =>
    return new this(node)


  @updateNodeAndCreate = (node, value) =>
    node.setValue(value)
    return new this(node)


  constructor: (@node) ->


  getValue: ->
    @node.getValue()


  mapValue: (map) ->
    new exports.ValuePayload(map(@getValue()))


  deliver: (targetNode) ->
    if not targetNode.setValue? and targetNode.receiveValue?
      targetNode.receiveValue(@getValue())
    else
      targetNode.setValue(@getValue())
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
