'use strict'


DuplexChannel = require './duplex_channel'


module.exports = class VariableChannel extends DuplexChannel

  mapPayloadValue = (map) ->
    (payload) -> payload.mapValue(map)

  withMapOrigin:  (map) -> @withTransformOrigin  mapPayloadValue(map)
  withMapDerived: (map) -> @withTransformDerived mapPayloadValue(map)


  withUpdateOrigin:  (update) -> @withMapDerived(update)
  withUpdateDerived: (update) -> @withMapOrigin(update)