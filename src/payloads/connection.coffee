'use strict'


{inspect} = require 'util'


class ConnectPayload

  @create = (origin) => new this(origin)


  constructor: (@origin) ->


  inspect: -> "connect (#{inspect @origin})"


  deliver: (line) ->
    line.setOrigin(@origin)
    line.connect()
    return this


class DisconnectPayload

  @create = (origin) => new this(origin)


  constructor: (@origin) ->


  inspect: -> "disconnect (#{inspect @origin})"


  deliver: (line) ->
    line.setOrigin(@origin)
    line.disconnect()
    return this


module.exports =
  connect: ConnectPayload.create
  disconnect: DisconnectPayload.create
