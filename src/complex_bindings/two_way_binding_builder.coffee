'use strict'


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


  bindOneWay: (source, target, transform)->
    @binder.buildOneWayBinding()
      .fromSource source
      .toTarget target
      .withTransform transform
      .bind()


  bind: ->
    @bindOneWay(@origin, @derived, @transformOrigin)
    @bindOneWay(@derived, @origin, @transformDerived)
    @binder.queryNodeState(@derived)
    return null
