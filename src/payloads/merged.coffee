'use strict'


{ValuePayload, StructPayload} = require '../transmission/payloads'



module.exports = class MergedPayload

  constructor: (@keys) ->
    @payloads = new Map()


  deliver: ->
    assert(false, "Can't deliver MergedPayload")


  reduceValue: (initial, reduce) ->
    result = initial
    for [node, payload] in Array.from(@payloads.entries())
      result = reduce(result, node, payload.getValue())
    new ValuePayload(result)


  fetch: (struct) ->
    new StructPayload(struct).map (key) => @payloads.get(key)


  replaceWithValue: (value) ->
    new ValuePayload(value)


  set: (key, payload) ->
    @payloads.set(key, payload)
    return this


  get: (key) ->
    @payloads.get(key)


  isPresent: ->
    @keys.every (key) => @payloads.get(key)?
