'use strict'


{forward, backward} = require '../binding/directions'


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


  bindOneWay: (source, target, transform, direction)->
    @binder.buildOneWayBinding()
      .inDirection direction
      .fromSource source
      .toTarget target
      .withTransform transform
      .bind()


  bind: ->
    @bindOneWay(@origin, @derived, @transformOrigin, forward)
    @bindOneWay(@derived, @origin, @transformDerived, backward)
    return null
