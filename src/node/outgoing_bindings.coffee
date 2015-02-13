'use strict'


module.exports = class OutgoingBindings

  constructor: ->
    @bindings = new Set()


  attach: (binding) ->
    @bindings.add(binding)
    return this


  propagate: (message) ->
    @bindings.forEach (binding) -> binding.propagate(message)
    return this

