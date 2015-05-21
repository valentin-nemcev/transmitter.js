'use strict'


{forward, backward} = require '../directions'
SimpleChannel = require './simple_channel'

ConnectionPayload = require '../payloads/connection'


module.exports = class BidirectionalChannel

  withOrigin:  (@origin)  -> this
  withDerived: (@derived) -> this


  withTransformOrigin:  (@transformOrigin)  -> this
  withTransformDerived: (@transformDerived) -> this


  getTransformOrigin: -> @transformOrigin
  getTransformDerived: -> @transformDerived



  _createSimple: (source, target, transform, direction) ->
    new SimpleChannel()
      .inDirection direction
      .fromSource source
      .toTarget target
      .withTransform transform


  _getForwardSimple: ->
    @forwardSimple ?=
      @_createSimple(@origin, @derived, @getTransformOrigin(), forward)


  _getBackwardSimple: ->
    @backwardSimple ?=
      @_createSimple(@derived, @origin, @getTransformDerived(), backward)


  connect: (tr) ->
    tr.createConnectionMessage(ConnectionPayload.connect())
      .sendToConnection(@_getForwardSimple())
      .sendToConnection(@_getBackwardSimple())
    return this


  receiveConnectionMessage: (message) ->
    @_getForwardSimple().receiveConnectionMessage(message)
    @_getBackwardSimple().receiveConnectionMessage(message)
    return this
