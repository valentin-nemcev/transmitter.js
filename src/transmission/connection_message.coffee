'use strict'


module.exports = class ConnectionMessage

  inspect: -> "CM #{@payload.inspect()}"


  @createInitial = (transmission, payload) ->
    new this(transmission, payload, {
      # precedence: 0
    })


  @createNext = (prevMessage, payload) ->
    new this(prevMessage.transmission, payload, {
      # precedence: prevMessage.precedence
    })


  constructor: (@transmission, @payload, opts = {}) ->
    # TODO
    {@precedence} = opts


  sendToConnection: (connection) ->
    connection.receiveConnectionMessage(this)
    return this


  passCommunication: (point, line) ->
    if comm = @transmission.getCommunicationFor(point)
      comm.sendToLine(line)
      @transmission.log 'passCommunication', this, line, comm
    return this


  communicationTypeOrder: 2


  getPrecedence: ->
    [@precedence, @communicationTypeOrder]


  sendToLine: (line) ->
    if @transmission.tryAddCommunicationFor(this, line)
      @payload.deliver(line)
    return this
