'use strict'


module.exports = class MessageSource

  constructor: ->
    @outgoingBindings = new Set()


  attachOutgoingBinding: (binding) ->
    @outgoingBindings.add(binding)
    return this


  send: (message) ->
    @outgoingBindings.forEach (binding) -> binding.send(message)
    return this
