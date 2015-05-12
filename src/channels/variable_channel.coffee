'use strict'


DuplexChannel = require './duplex_channel'


module.exports = class VariableChannel extends DuplexChannel

  createTransform = (map, match) ->
    if match?
      (payload) -> payload.update (source, target) ->
        if match(source, target) then target else map(source)
    else
      (payload) -> payload.map(map)


  getTransformOrigin:  -> createTransform(@mapOrigin,  @matchOriginDerived)
  getTransformDerived: -> createTransform(@mapDerived, @matchDerivedOrigin)

  withMapOrigin:  (@mapOrigin)  -> this
  withMapDerived: (@mapDerived) -> this


  withMatchDerivedOrigin: (@matchDerivedOrigin) -> this
  withMatchOriginDerived: (@matchOriginDerived) -> this



  withUpdateOrigin:  (update) -> @withMapDerived(update)
  withUpdateDerived: (update) -> @withMapOrigin(update)
