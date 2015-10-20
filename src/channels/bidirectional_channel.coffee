'use strict'


{inspect} = require 'util'

directions = require '../directions'

getNullChannel = require './null_channel'
SimpleChannel = require './simple_channel'
CompositeChannel = require './composite_channel'


module.exports = class BidirectionalChannel extends CompositeChannel

  inspect: ->
    '(' + [@origin, @getDirection(), @derived].map(inspect).join('') + ')'


  inForwardDirection: -> @inDirection(directions.forward)
  inBackwardDirection: -> @inDirection(directions.backward)


  inDirection: (@direction) ->
    return this


  getDirection: ->
    @direction ? directions.omni


  withOrigin:  (@origin)  -> this
  withDerived: (@derived) -> this


  withTransformOrigin:  (@transformOrigin)  -> this
  withTransformDerived: (@transformDerived) -> this


  withMapOrigin:  (@mapOrigin)  -> this
  withMapDerived: (@mapDerived) -> this


  withMatchDerivedOrigin: (@matchDerivedOrigin) -> this
  withMatchOriginDerived: (@matchOriginDerived) -> this


  getMatchOriginDerived: ->
      @matchOriginDerived ?=
        if @matchDerivedOrigin?
          (origin, derived) => @matchDerivedOrigin(derived, origin)

  getMatchDerivedOrigin: ->
      @matchDerivedOrigin ?=
        if @matchOriginDerived?
          (derived, origin) => @matchOriginDerived(origin, derived)


  id = (a) -> a

  createTransform = (map, match) ->
    if match?
      (payload, tr) -> payload.updateMatching(( -> map(arguments..., tr)), match)
    else
      (payload, tr) -> payload.map( -> map(arguments..., tr))


  getTransformOrigin:  -> @transformOrigin ?
    createTransform(@mapOrigin ? id,  @getMatchOriginDerived())

  getTransformDerived: -> @transformDerived ?
    createTransform(@mapDerived ? id, @getMatchDerivedOrigin())


  createSimple = (source, target, transform, direction) ->
    new SimpleChannel()
      .inDirection direction
      .fromSource source
      .toTarget target
      .withTransform transform


  @defineChannel ->
    if @getDirection().matches(directions.forward)
      createSimple(@origin, @derived, @getTransformOrigin())
        .inForwardDirection()
    else
      getNullChannel()


  @defineChannel ->
    if @getDirection().matches(directions.backward)
      createSimple(@derived, @origin, @getTransformDerived())
        .inBackwardDirection()
    else
      getNullChannel()
