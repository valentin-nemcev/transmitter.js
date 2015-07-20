'use strict'


SimpleChannel = require './simple_channel'
CompositeChannel = require './composite_channel'

ConnectionPayload = require '../payloads/connection'


module.exports = class BidirectionalChannel extends CompositeChannel

  inspect: -> '[' + @constructor.name + ']'


  withOrigin:  (@origin)  -> this
  withDerived: (@derived) -> this


  withTransformOrigin:  (@transformOrigin)  -> this
  withTransformDerived: (@transformDerived) -> this


  withMapOrigin:  (@mapOrigin)  -> this
  withMapDerived: (@mapDerived) -> this


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
    createSimple(@origin, @derived, @getTransformOrigin())
      .inForwardDirection()


  @defineChannel ->
    createSimple(@derived, @origin, @getTransformDerived())
      .inBackwardDirection()
