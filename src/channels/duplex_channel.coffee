'use strict'


{forward, backward} = require '../directions'
ConnectionBuilder = require '../connection/builder'


module.exports = class DuplexChannel

  withOrigin:  (@origin)  -> this
  withDerived: (@derived) -> this


  withTransformOrigin:  (@transformOrigin)  -> this
  withTransformDerived: (@transformDerived) -> this


  createConnection: (source, target, transform, direction) ->
    new ConnectionBuilder()
      .inDirection direction
      .fromSource source
      .toTarget target
      .withTransform transform


  getForwardConnection: ->
    @forwardConnection ?=
      @createConnection(@origin, @derived, @transformOrigin, forward)


  getBackwardConnection: ->
    @backwardConnection ?=
      @createConnection(@derived, @origin, @transformDerived, backward)


  connect: ->
    Transmitter = require '../transmitter'
    Transmitter.connect(@getForwardConnection())
    Transmitter.connect(@getBackwardConnection())
    return null


  receiveConnectionMessage: (message) ->
    @getForwardConnection().receiveConnectionMessage(message)
    @getBackwardConnection().receiveConnectionMessage(message)
    return this