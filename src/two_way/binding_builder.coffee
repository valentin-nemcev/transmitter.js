'use strict'


module.exports = class TwoWayBindingBuilder

  constructor: (@binder) ->


  withOrigin: (@origin) ->
    return this


  withDerived: (@derived) ->
    return this


  bindForward: ->
    @binder.buildOneWayBinding()
      .fromSource @origin
      .toTarget @derived
      .bind()


  bindBackward: ->
    @binder.buildOneWayBinding()
      .fromSource @derived
      .toTarget @origin
      .bind()


  bind: ->
    @bindForward()
    @bindBackward()
    return null
