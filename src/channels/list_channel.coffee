'use strict'


BidirectionalChannel = require './bidirectional_channel'
SimpleChannel = require './simple_channel'
ChannelList = require '../channel_nodes/channel_list'
ListPayload = require '../payloads/list'
noop = require '../payloads/noop'


module.exports = class ListChannel extends BidirectionalChannel

  withMatchOriginDerivedChannel: (@matchOriginDerivedChannel) ->
    return this


  @defineLazy 'nestedChannelList', -> new ChannelList()

  withOriginDerivedChannel: (createOriginDerivedChannel) ->
    @defineChannel ->
      new SimpleChannel()
        .fromSource @origin
        .fromSource @derived
        .toConnectionTarget @nestedChannelList
        .withTransform (lists) =>
          origin = lists.get(@origin)
          derived = lists.get(@derived)

          unless origin.getPriority() == derived.getPriority()
            return noop()

          zipped = ListPayload.setLazy( -> origin.get().zip(derived.get()))

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
