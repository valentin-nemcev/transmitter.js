'use strict'

assert = require 'assert'

module.exports = class ConnectionMessage

  inspect: -> "CM #{@payload.inspect()}"


  constructor: (@transmission, @payload) ->
    assert(@payload, 'Message must have payload')


  sendToConnection: (connection) ->
    connection.receiveConnectionMessage(this)
    return this


  passMessage: (node, line) ->
    if message = @transmission.getMessageFor(node)
      line.receiveMessage(message)
    return this


  passQuery: (node, line) ->
    if query = @transmission.getQueryFor(node)
      line.receiveQuery(query)
    return this


  deliverToLine: (line) ->
    return this if @transmission.hasMessageFor(line)
    @transmission.addMessageFor(this, line)
    @payload.deliver(line)
    return this
