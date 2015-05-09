'use strict'


assert = require 'assert'
{inspect} = require 'util'


class exports.ValuePayload

  @create = (value) => new this(value)

  constructor: (@value) ->


  inspect: -> "value: #{inspect @value}"


  get: -> @value


  map: (map) ->
    if @value?
      new exports.ValuePayload(map(@value))
    else
      this


  flatMap: (map) ->
    if @value?
      map(@value)
    else
      this


  deliverToEventTarget: (targetNode) ->
    targetNode.receiveValue(@value)
    return this


  deliver: (targetNode) ->
    targetNode.setValue(@value)
    return this



class exports.ListPayload

  constructor: (@list) ->


  inspect: -> "list: #{inspect @value}"


  map: (map) ->
    return new exports.ListPayload(@list.map(map))


  deliverToEventTarget: (targetNode) ->
    targetNode.receiveValue(@list)
    return this


  deliver: (targetNode) ->
    targetNode.setValue(@list)
    return this



class exports.StatePayload

  @create = (node) =>
    return new this(node)


  @createFromValue = (value) =>
    return new this(get: -> value)


  constructor: (@node, @update) ->


  inspect: -> "state: #{inspect @node}"


  toValue: ->
    new exports.ValuePayload(@get())


  get: ->
    @node.get()


  map: (map) ->
    new exports.StatePayload(@node, map)


  deliverToEventTarget: (targetNode) ->
    targetNode.receiveValue(@get())
    return this


  deliver: (targetNode) ->
    value = if @update?
      @update(@get(), targetNode.get())
    else
      @get()
    targetNode.setValue(value)
    return this



class exports.StructPayload


  @createStructOrValue = (value) ->
    if value?.constructor in [Object, Array]
      new exports.StructPayload(value)
    else
      value


  constructor: (value = {}) ->
    this[key] = val for own key, val of value


  get: ->
    result = if @length? then [] else {}
    result[key] = val for own key, val of this
    return result


  morph: (morph) ->
    @constructor.createStructOrValue(morph(@get()))

  map: (map) ->
    result = new @constructor()
    result[key] = map(val, key) for own key, val of this
    return result


  zip: ->
    result = []
    for own key, val of this
      for el, i in val.get()
        result[i] ?= new @constructor()
        result[i][key] = el

    return new exports.ListPayload(result)
