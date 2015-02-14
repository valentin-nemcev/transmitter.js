'use strict'


module.exports = class MessageTarget

  constructor: (@node) ->


  send: (message) ->
    message.sendTo(@node)
    return this
