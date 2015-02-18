'use strict'


module.exports = class MessageTarget

  constructor: (@node) ->


  send: (message) ->
    message.deliver(@node)
    return this
