'use strict'


{forward, backward} = require './directions'
ConnectionBuilder = require './connection/builder'


module.exports = class ChannelBuilder

  constructor: (@Transmitter) ->


  withOrigin:  (@origin)  -> this
  withDerived: (@derived) -> this


  withTransformOrigin:  (@transformOrigin)  -> this
  withTransformDerived: (@transformDerived) -> this


  mapPayloadValue = (map) ->
    (payload) -> payload.mapValue(map)

  withMapOrigin:  (map) -> @withTransformOrigin  mapPayloadValue(map)
  withMapDerived: (map) -> @withTransformDerived mapPayloadValue(map)


  withUpdateOrigin:  (update) -> @withMapDerived(update)
  withUpdateDerived: (update) -> @withMapOrigin(update)


  createConnection: (source, target, transform, direction) ->
    new ConnectionBuilder(@Transmitter)
      .inDirection direction
      .fromSource source
      .toTarget target
      .withTransform transform


  getForwardConnection: ->
    @forwardConnection ?=
      @createConnection(@origin, @derived, @transformOrigin, forward)


  getBackwardConnection: ->
    @backwardConnection ?=
      @createConnection(@derived, @origin, @transformDerived, backward)


  connect: ->
    @getForwardConnection().connect()
    @getBackwardConnection().connect()
    return null


  receiveConnectionMessage: (message) ->
    @getForwardConnection().receiveConnectionMessage(message)
    @getBackwardConnection().receiveConnectionMessage(message)
    return this
