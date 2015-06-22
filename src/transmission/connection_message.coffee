'use strict'


module.exports = class ConnectionMessage

  inspect: -> "CM #{@payload.inspect()}"


  @createInitial = (transmission, payload) ->
    new this(transmission, payload)


  @createNext = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload)


  constructor: (@transmission, @payload, opts = {}) ->
    {@precedence} = opts


  sendToConnection: (connection) ->
    connection.receiveConnectionMessage(this)
    return this


  passMessage: (point, line) ->
    if message = @transmission.getMessageFor(point)
      message.sendToLine(line)
      @transmission.log 'passMessage', this, line, message
    return this


  passQuery: (point, line) ->
    if query = @transmission.getQueryFor(point)
      query.sendToLine(line)
      @transmission.log 'passQuery', this, line, query
    return this


  hasPrecedenceOver: (prev) ->
    not prev? or this.precedence > prev.precedence


  sendToLine: (line) ->
    unless @hasPrecedenceOver(@transmission.getMessageFor(line))
      return this
    @transmission.addMessageFor(this, line)
    @payload.deliver(line)
    return this
