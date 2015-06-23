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


  passCommunication: (point, line) ->
    if comm = @transmission.getCommunicationFor(point)
      comm.sendToLine(line)
      @transmission.log 'passCommunication', this, line, comm
    return this


  hasPrecedenceOver: (prev) ->
    not prev? or this.precedence > prev.precedence


  sendToLine: (line) ->
    if @hasPrecedenceOver(@transmission.getCommunicationFor(line))
      @transmission.addCommunicationFor(this, line)
      @payload.deliver(line)
    # unless @hasPrecedenceOver(@transmission.getMessageFor(line))
    #   return this
    # @transmission.addMessageFor(this, line)
    # @payload.deliver(line)
    return this
