'use strict'

assert = require 'assert'

module.exports = class ConnectionMessage

  constructor: (@transmission, @payload) ->
    assert(@payload, 'Message must have payload')


  sendToConnection: (connection) ->
    connection.receiveConnectionMessage(this)
    return this


  deliverToLine: (line) ->
    @payload.deliver(line)
    return this
