'use strict'


{inspect} = require 'util'


module.exports = class ConnectionPayload

  @connect = (origin) -> new this(origin)


  constructor: (@origin) ->


  inspect: -> "connect (#{inspect @origin})"


  deliver: (line) ->
    line.setOrigin(@origin)
    line.connect()
    return this
