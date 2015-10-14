'use strict'


BidirectionalChannel = require './bidirectional_channel'
CompositeChannel = require './composite_channel'
SimpleChannel = require './simple_channel'
ChannelList = require '../channel_nodes/channel_list'
ListPayload = require '../payloads/list'
noop = require '../payloads/noop'


CompositeChannel::defineListChannel = ->
  channel = new ListChannel()
  @addChannel(channel)
  return channel


module.exports = class ListChannel extends BidirectionalChannel

  withMatchOriginDerivedChannel: (@matchOriginDerivedChannel) ->
    return this


  constructor: ->
    super
    @nestedChannelList = new ChannelList()


  withOriginDerivedChannel: (createOriginDerivedChannel) ->
    @defineChannel ->
      new SimpleChannel()
        .fromSource @origin
        .fromSource @derived
        .requireMatchingSourcePriorities()
        .toConnectionTarget @nestedChannelList
        .withTransform (payloads) =>
          return payloads unless payloads.length?
          [origin, derived] = payloads

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
