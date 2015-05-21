'use strict'


BidirectionalChannel = require './bidirectional_channel'


module.exports = class ListChannel extends BidirectionalChannel

  mapPayloadValue = (map) ->
    (payload) ->
      payload.map (list) ->
        list.map map

  withMapOrigin:  (map) -> @withTransformOrigin  mapPayloadValue(map)
  withMapDerived: (map) -> @withTransformDerived mapPayloadValue(map)


  withUpdateOrigin:  (update) -> @withMapDerived(update)
  withUpdateDerived: (update) -> @withMapOrigin(update)
