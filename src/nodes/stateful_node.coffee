'use strict'


NodeSource = require '../connection/node_source'
NodeTarget = require '../connection/node_target'

module.exports = class StatefulNode

    NodeSource.extend this
    NodeTarget.extend this

    getResponseMessage: (sender) -> sender.createStateMessage(this)
    getOriginMessage:   (sender) -> sender.createStateMessage(this)
    getRelayedMessage:  (sender) -> sender.createStateMessage(this)
