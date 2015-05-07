'use strict'


{forward, backward} = require '../directions'
SimplexChannel = require './simplex_channel'

ConnectionPayload = require '../payloads/connection'


module.exports = class DuplexChannel

  withOrigin:  (@origin)  -> this
  withDerived: (@derived) -> this


  withTransformOrigin:  (@transformOrigin)  -> this
  withTransformDerived: (@transformDerived) -> this


  _createSimplex: (source, target, transform, direction) ->
    new SimplexChannel()
      .inDirection direction
      .fromSource source
      .toTarget target
      .withTransform transform


  _getForwardSimplex: ->
    @forwardSimplex ?=
      @_createSimplex(@origin, @derived, @transformOrigin, forward)


  _getBackwardSimplex: ->
    @backwardSimplex ?=
      @_createSimplex(@derived, @origin, @transformDerived, backward)


  connect: (tr) ->
    tr.createConnectionMessage(ConnectionPayload.connect())
      .sendToConnection(@_getForwardSimplex())
      .sendToConnection(@_getBackwardSimplex())
    return null


  receiveConnectionMessage: (message) ->
    @_getForwardSimplex().receiveConnectionMessage(message)
    @_getBackwardSimplex().receiveConnectionMessage(message)
    return this
