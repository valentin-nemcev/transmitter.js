'use strict'


class exports.EventPayload

  toValue: (value) -> new exports.ValuePayload(value)



class exports.ValuePayload

  constructor: (@value) ->


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


  mapValue: (map) ->
    new exports.ValuePayload(map(@node.getValue()))


  deliver: (targetNode) ->
    if not targetNode.setValue? and targetNode.receiveValue?
      targetNode.receiveValue(@node.getValue())
    else
      targetNode.setValue(@node.getValue())
    return this


class exports.MergedPayload

  constructor: (@keys) ->
    @payloads = new Map()


  set: (key, payload) ->
    @payloads.set(key, payload)
    return this


  get: (key) ->
    @payloads.get(key)


  isPresent: ->
    @keys.every (key) => @payloads.get(key)?
