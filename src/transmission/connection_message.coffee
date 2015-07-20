'use strict'


FastSet = require 'collections/fast-set'


module.exports = class ConnectionMessage

  inspect: ->
    [
      'CM'
      # 'P:' + @precedence
      @origin.inspect()
    ].join(' ')


  log: ->
    @transmission.log this, arguments...
    return this


  # @createInitial = (transmission, payload) ->
  #   new this(transmission, payload, {
  #     # precedence: 0
  #   })


  @createNext = (prevMessage, origin) ->
    new this(prevMessage.transmission, origin, {
      # precedence: prevMessage.precedence
    })


  constructor: (@transmission, @origin, opts = {}) ->
    # TODO
    {@precedence} = opts
    @points = new FastSet()


  getOrigin: -> @origin


  addPoint: (point) ->
    @points.add(point)
    return this


  updatePoints: ->
    @points.forEach (point) =>
      @log point
      if comm = @transmission.getCommunicationFor(point)
        point.passCommunication(comm, @origin)

    return this


  sendToConnection: (connection) ->
    connection.receiveConnectionMessage(this)
    return this


  # passCommunication: (point, line) ->
  #   if comm = @transmission.getCommunicationFor(point)
  #     comm.sendToLine(line)
  #     @transmission.log 'passCommunication', this, line, comm
  #   return this


  communicationTypeOrder: 2


  getPrecedence: ->
    [@precedence, @communicationTypeOrder]


  sendToLine: (line) ->
    if @transmission.tryAddCommunicationFor(this, line)
      @payload.deliver(line)
    return this
