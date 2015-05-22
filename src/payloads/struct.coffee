'use strict'


ListPayload = require './list'


module.exports = class StructPayload

  @createStructOrValue = (value) ->
    if value?.constructor in [Object, Array]
      new StructPayload(value)
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

    return ListPayload.createFromValue(result)
