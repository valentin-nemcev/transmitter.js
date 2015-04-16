'use strict'

assert = require 'assert'

module.exports = class ConnectionMessage

  constructor: (@transmission, @payload) ->
    assert(@payload, 'Message must have payload')


  sendToConnection: (connection) ->
    connection.receiveConnectionMessage(this)
    return this


  passMessage: (node, line) ->
    if message = @transmission.getMessageFrom(node)
      line.receiveMessage(message)
    return this


  deliverToLine: (line) ->
    return this if @transmission.hasMessageForNode(line)
    @transmission.addMessageForNode(this, line)
    @payload.deliver(line)
    return this
