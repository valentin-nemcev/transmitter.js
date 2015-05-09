'use strict'


{ValuePayload, StructPayload} = require '../transmission/payloads'



module.exports = class MergedPayload

  constructor: (@keys) ->
    @payloads = new Map()


  deliver: ->
    assert(false, "Can't deliver MergedPayload")


  reduce: (initial, reduce) ->
    result = initial
    for [node, payload] in Array.from(@payloads.entries())
      result = reduce(result, node, payload.get())
    new ValuePayload(result)


  fetch: (struct) ->
    new StructPayload(struct).map (key) => @getAt(key)


  setAt: (key, payload) ->
    @payloads.set(key, payload)
    return this


  getAt: (key) ->
    @payloads.get(key)


  isPresent: ->
    @keys.every (key) => @payloads.get(key)?
