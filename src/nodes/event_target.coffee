'use strict'


NodeTarget = require '../connection/node_target'


module.exports = class EventTarget

  NodeTarget.extend this

  routeMessage: (payload, sender) ->
    payload.deliver(this)
    return this
