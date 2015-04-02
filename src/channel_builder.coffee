'use strict'


{forward, backward} = require './directions'
ConnectionBuilder = require './connection/builder'


module.exports = class ChannelBuilder

  constructor: ->


  withOrigin:  (@origin)  -> this
  withDerived: (@derived) -> this

  withTransformOrigin:  (@transformOrigin)  -> this
  withTransformDerived: (@transformDerived) -> this

  mapPayloadValue = (map) ->
    (payload) -> payload.mapValue(map)

  withMapOrigin:  (map) -> @withTransformOrigin  mapPayloadValue(map)
  withMapDerived: (map) -> @withTransformDerived mapPayloadValue(map)


  connectDirection: (source, target, transform, direction)->
    new ConnectionBuilder()
      .inDirection direction
      .fromSource source
      .toTarget target
      .withTransform transform
      .connect()


  connect: ->
    @connectDirection(@origin, @derived, @transformOrigin, forward)
    @connectDirection(@derived, @origin, @transformDerived, backward)
    return null
