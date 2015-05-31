'use strict'

assert = require 'assert'

module.exports = class ConnectionMessage

  inspect: -> "CM #{@payload.inspect()}"


  constructor: (@transmission, @payload) ->
    #TODO: precedence
    assert(@payload, 'Message must have payload')


  sendToConnection: (connection) ->
    connection.receiveConnectionMessage(this)
    return this


  passMessage: (point, line) ->
    if message = @transmission.getMessageFor(point)
      line.receiveMessage(message)
    @transmission._log 'passMessage', this, point, line, message
    return this


  passQuery: (point, line) ->
    if query = @transmission.getQueryFor(point)
      line.receiveQuery(query)
    return this


  sendToLine: (line) ->
    return this if @transmission.hasMessageFor(line)
    @transmission.addMessageFor(this, line)
    @payload.deliver(line)
    return this
