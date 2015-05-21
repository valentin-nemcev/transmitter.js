'use strict'


{forward, backward} = require '../directions'

SimpleChannel = require './simple_channel'
CompositeChannel = require './composite_channel'

ConnectionPayload = require '../payloads/connection'


module.exports = class BidirectionalChannel extends CompositeChannel

  withOrigin:  (@origin)  -> this
  withDerived: (@derived) -> this


  withTransformOrigin:  (@transformOrigin)  -> this
  withTransformDerived: (@transformDerived) -> this


  getTransformOrigin: -> @transformOrigin
  getTransformDerived: -> @transformDerived


  createSimple = (source, target, transform, direction) ->
    new SimpleChannel()
      .inDirection direction
      .fromSource source
      .toTarget target
      .withTransform transform


  @defineChannel ->
    createSimple(@origin, @derived, @getTransformOrigin(), forward)


  @defineChannel ->
    createSimple(@derived, @origin, @getTransformDerived(), backward)
