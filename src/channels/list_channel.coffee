'use strict'


BidirectionalChannel = require './bidirectional_channel'
SimpleChannel = require './simple_channel'
ChannelList = require '../channel_nodes/channel_list'


module.exports = class ListChannel extends BidirectionalChannel

  mapPayloadValue = (map) ->
    (payload) ->
      payload.map map

  withMapOrigin:  (map) -> @withTransformOrigin  mapPayloadValue(map)
  withMapDerived: (map) -> @withTransformDerived mapPayloadValue(map)


  withUpdateOrigin:  (update) -> @withMapDerived(update)
  withUpdateDerived: (update) -> @withMapOrigin(update)

  withOriginDerivedChannel: (createOriginDerivedChannel) ->
    @nestedListChannelNode = new ChannelList()
    @defineChannel ->
      new SimpleChannel()
        .fromSource @origin
        .fromSource @derived
        .toConnectionTarget @nestedListChannelNode
        .withTransform (lists) =>
          lists.fetch([@origin, @derived]).zip()
            .map ([originItem, derivedItem]) ->
              createOriginDerivedChannel(originItem, derivedItem)
