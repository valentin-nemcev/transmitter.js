'use strict'


BidirectionalChannel = require './bidirectional_channel'
SimpleChannel = require './simple_channel'
ChannelList = require '../channel_nodes/channel_list'
Payloads = require '../payloads'


module.exports = class ListChannel extends BidirectionalChannel

  withOriginDerivedChannel: (createOriginDerivedChannel) ->
    @nestedListChannelNode = new ChannelList()
    @defineChannel ->
      new SimpleChannel()
        .fromSource @origin
        .fromSource @derived
        .toConnectionTarget @nestedListChannelNode
        .withTransform (lists) =>
          origin = lists.get(@origin)
          derived = lists.get(@derived)
          Payloads.set ->
            origin.get().zip(derived.get()).map ([originItem, derivedItem]) ->
              createOriginDerivedChannel(originItem, derivedItem)
