'use strict'


{StatePayload} = require '../transmission/payloads'

NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'

module.exports = class StatefulNode

    NodeSource.extend this
    NodeTarget.extend this

    createResponsePayload: -> StatePayload.create(this)
    createOriginPayload:   -> StatePayload.create(this)
    createRelayPayload :   -> StatePayload.create(this)
