'use strict'


BidirectionalChannel = require './bidirectional_channel'
SimpleChannel = require './simple_channel'
ChannelList = require '../channel_nodes/channel_list'
ListPayload = require '../payloads/list'


module.exports = class ListChannel extends BidirectionalChannel

  withMatchOriginDerivedChannel: (@matchOriginDerivedChannel) ->
    return this


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
          zipped = ListPayload.setLazy( ->
            unless origin.getSize() == derived.getSize()
              console.warn "Different size #{origin.inspect()}, #{derived.inspect()}"
            origin.get().zip(derived.get())
          )
          if @matchOriginDerivedChannel?
            zipped.updateMatching(
              ([originItem, derivedItem]) ->
                createOriginDerivedChannel(originItem, derivedItem)
              ([originItem, derivedItem], channel) =>
                @matchOriginDerivedChannel(originItem, derivedItem, channel)
            )
          else
            zipped.map(
              ([originItem, derivedItem]) ->
                createOriginDerivedChannel(originItem, derivedItem)
            )
