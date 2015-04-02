'use strict'


{forward, backward} = require '../directions'


module.exports = class TwoWayBindingBuilder

  constructor: (@binder) ->


  withOrigin:  (@origin)  -> this
  withDerived: (@derived) -> this

  withTransformOrigin:  (@transformOrigin)  -> this
  withTransformDerived: (@transformDerived) -> this

  mapPayloadValue = (map) ->
    (payload) -> payload.mapValue(map)

  withMapOrigin:  (map) -> @withTransformOrigin  mapPayloadValue(map)
  withMapDerived: (map) -> @withTransformDerived mapPayloadValue(map)


  connect: (source, target, transform, direction)->
    @binder.connection()
      .inDirection direction
      .fromSource source
      .toTarget target
      .withTransform transform
      .connect()


  bind: ->
    @connect(@origin, @derived, @transformOrigin, forward)
    @connect(@derived, @origin, @transformDerived, backward)
    return null
