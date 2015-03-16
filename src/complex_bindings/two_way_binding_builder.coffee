'use strict'


module.exports = class TwoWayBindingBuilder

  constructor: (@binder) ->


  withOrigin: (@origin) ->
    return this


  withDerived: (@derived) ->
    return this


  bindOneWay: (source, target)->
    @binder.buildOneWayBinding()
      .fromSource source
      .toTarget target
      .bind()


  bind: ->
    @bindOneWay(@origin, @derived)
    @bindOneWay(@derived, @origin)
    @binder.enquire(@derived)
    return null
