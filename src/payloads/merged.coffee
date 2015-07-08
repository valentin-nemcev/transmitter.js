'use strict'


Map = require 'collections/map'

StructPayload = require './struct'
ValuePayload = require './value'


module.exports = class MergedPayload

  inspect: ->
    payloads = @payloads.map (payload, node) ->
      node.inspect() + ': ' + payload.inspect()
    "merged(#{payloads.join(', ')})"


  constructor: (payloads) ->
    @payloads = new Map()
    for [key, payload] in payloads
      @payloads.set(key, payload)


  deliver: ->
    assert(false, "Can't deliver MergedPayload")


  reduce: (initial, reduce) ->
    result = initial
    @payloads.forEach (payload, node) ->
      result = reduce(result, node, payload.get())
    ValuePayload.createFromValue(result)


  fetch: (struct) ->
    new StructPayload(struct).map (key) => @getAt(key)


  getAt: (key) ->
    @payloads.get(key)


  isPresent: ->
    @keys.every (key) => @payloads.get(key)?
