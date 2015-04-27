'use strict'


NodeSource = require '../connection/node_source'


module.exports = class EventSource

  NodeSource.extend this

  getResponseMessage:      (sender) -> sender.createValueMessage(null)
  getOriginMessage: (sender, value) -> sender.createValueMessage(value)
