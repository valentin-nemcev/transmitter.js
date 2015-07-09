'use strict'


{inspect} = require 'util'


class SetPayload

  @create = (getValue) -> new SetPayload({get: getValue})


  id = (a) -> a
  getNull = -> null

  inspect: -> "value(#{inspect @get()})"

  constructor: (@source, opts = {}) ->
    @mapFn = opts.map ? id
    @ifEmptyFn = opts.ifEmpty ? getNull


  get: ->
    if (value = @source.get())?
      @mapFn.call(null, value)
    else
      @ifEmptyFn.call(null)


  deliverValueState: (variable) ->
    variable.set(@get())
    return this


module.exports = SetPayload.create
