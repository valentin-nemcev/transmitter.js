'use strict'


{ValuePayload} = require '../transmission/payloads'

NodeSource = require '../connection/node_source'


module.exports = class EventSource

  NodeSource.extend this

  createResponsePayload: -> ValuePayload.create(null)
  createOriginPayload: (value) -> ValuePayload.create(value)
