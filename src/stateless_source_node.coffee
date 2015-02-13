'use strict'


OutgoingBindings = require './node/outgoing_bindings'
Message = require './message'


module.exports = class StatelessSourceNode

  constructor: ->
    @outgoingBindings = new OutgoingBindings()


  attachOutgoingBinding: (binding) ->
    @outgoingBindings.attach(binding)
    return this


  send: ->
    @outgoingBindings.propagate(Message.createBare())
