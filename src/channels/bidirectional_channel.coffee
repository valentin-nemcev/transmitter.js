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


  withMapOrigin:  (@mapOrigin)  -> this
  withMapDerived: (@mapDerived) -> this

  initOrigin:  -> @initsOrigin = yes;  this
  initDerived: -> @initsDerived = yes; this

  withMatchDerivedOrigin: (@matchDerivedOrigin) -> this
  withMatchOriginDerived: (@matchOriginDerived) -> this


  getMatchOriginDerived: ->
      @matchOriginDerived or
        if @matchDerivedOrigin?
          (origin, derived) => @matchDerivedOrigin(derived, origin)

  getMatchDerivedOrigin: ->
      @matchDerivedOrigin or
        if @matchOriginDerived?
          (derived, origin) => @matchOriginDerived(origin, derived)


  wrapMap = (map, tr, inits) ->
    if inits
      -> map(arguments...).init(tr)
    else
      map


  createTransform = (map, match, inits) ->
    if match?
      (payload, tr) -> payload.mapIfMatch(wrapMap(map, tr, inits), match)
    else
      (payload, tr) -> payload.map(wrapMap(map, tr, inits))


  getTransformOrigin:  -> @transformOrigin ?
    createTransform(@mapOrigin,  @getMatchOriginDerived(), @initsOrigin)

  getTransformDerived: -> @transformDerived ?
    createTransform(@mapDerived, @getMatchDerivedOrigin(), @initsDerived)


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
