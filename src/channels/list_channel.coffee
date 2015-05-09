'use strict'


DuplexChannel = require './duplex_channel'


module.exports = class ListChannel extends DuplexChannel

  mapPayloadValue = (map) ->
    (payload) ->
      payload.map (list) ->
        list.map map

  withMapOrigin:  (map) -> @withTransformOrigin  mapPayloadValue(map)
  withMapDerived: (map) -> @withTransformDerived mapPayloadValue(map)


  withUpdateOrigin:  (update) -> @withMapDerived(update)
  withUpdateDerived: (update) -> @withMapOrigin(update)
