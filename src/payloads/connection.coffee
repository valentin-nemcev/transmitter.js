'use strict'


{inspect} = require 'util'


class ConnectPayload

  @create = (origin) => new this(origin)


  constructor: (@origin) ->


  inspect: -> "connect (#{inspect @origin})"


  deliver: (line) ->
    line.connect(@origin)
    return this


class DisconnectPayload

  @create = (origin) => new this(origin)


  constructor: (@origin) ->


  inspect: -> "disconnect (#{inspect @origin})"


  deliver: (line) ->
    line.disconnect()
    return this


module.exports =
  connect: ConnectPayload.create
  disconnect: DisconnectPayload.create
