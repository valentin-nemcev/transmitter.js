'use strict'


module.exports = class StatelessTargetNode

  constructor: ->
    @incomingBindings = new Set()


  attachIncomingBinding: (binding) ->
    @incomingBindings.add(binding)
    return this


  send: (message) ->
    message.sendTo(this)
    return this
