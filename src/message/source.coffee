'use strict'


module.exports = class MessageSource

  constructor: ->
    @targets = new Set()


  bindTarget: (target) ->
    @targets.add(target)
    return this


  send: (message) ->
    @targets.forEach (target) -> target.send(message)
    return this
