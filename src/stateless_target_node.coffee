'use strict'


module.exports = class StatelessTargetNode

  constructor: ->
    @incomingBindings = new Set()


  attachIncomingBinding: (binding) ->
    @incomingBindings.add(binding)
    return this


  propagate: (message) ->
    message.propagateTo(this)
    return this
