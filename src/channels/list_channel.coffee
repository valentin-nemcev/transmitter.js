'use strict'

{inspect} = require 'util'

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
    createChannel = ([originItem, derivedItem]) =>
      match = @getMatchOriginDerived()
      if match? and not match(originItem, derivedItem)
        throw new Error "Binding mismatched items: " + \
                          [originItem, derivedItem].map(inspect).join(' ')
      createOriginDerivedChannel(originItem, derivedItem)

    matchChannel = if @matchOriginDerivedChannel?
      ([originItem, derivedItem], channel) =>
        @matchOriginDerivedChannel(originItem, derivedItem, channel)

    @defineChannel ->
      new SimpleChannel()
        .fromSource @origin
        .fromSource @derived
        .requireMatchingSourcePriorities()
        .toConnectionTarget @nestedChannelList
        .withTransform (payloads) =>
          return payloads unless payloads.length?

          [origin, derived] = payloads

          zipped = origin.zip(derived)

          if matchChannel?
            zipped.updateMatching(createChannel, matchChannel)
          else
            zipped.map(createChannel)
