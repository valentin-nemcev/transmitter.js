'use strict'


NodeTarget = require '../connection/node_target'


module.exports = class EventTarget

  NodeTarget.extend this

  routeMessage: (payload, tr) ->
    payload.deliver(this)
    return this
