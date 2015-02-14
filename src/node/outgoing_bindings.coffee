'use strict'


module.exports = class OutgoingBindings

  constructor: ->
    @bindings = new Set()


  attach: (binding) ->
    @bindings.add(binding)
    return this


  send: (message) ->
    @bindings.forEach (binding) -> binding.send(message)
    return this

