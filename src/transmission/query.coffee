'use strict'


{inspect} = require 'util'

FastSet = require 'collections/fast-set'
Pass = require './pass'
Nesting = require './nesting'
Precedence = require './precedence'


class NullQuery
  sendFromNodeToNodeTarget: -> this
  enqueueForSourceNode: -> this


module.exports = class Query

  inspect: ->
    [
      'Q',
      # inspect @nesting
      inspect @pass
      @wasDelivered() and 'D' or ''
    ].filter( (s) -> s.length).join(' ')


  log: ->
    args = [this]
    args.push arg for arg in arguments
    @transmission.log args...
    return this


  @getNullQuery = -> @nullQuery ?= new NullQuery()

  getNullQuery: -> Query.getNullQuery()


  @createInitial = (transmission) ->
    new this(transmission,
      pass: Pass.createQueryDefault(),
      nesting: Nesting.createInitial()
    )


  @createNext = (prevQuery) ->
    new this(prevQuery.transmission, {
      pass: prevQuery.pass
      nesting: prevQuery.nesting
    })


  @createNextConnection = (prevMessageOrQuery) ->
    new this(prevMessageOrQuery.transmission, {
      pass: prevMessageOrQuery.pass
      nesting: prevMessageOrQuery.nesting.decrease()
    })


  @createForMerge = (mergedMessage) ->
    new this(mergedMessage.transmission, {
      pass: mergedMessage.pass
      nesting: mergedMessage.nesting
    })


  @createForSelect = (selectedMessage) ->
    new this(selectedMessage.transmission, {
      pass: selectedMessage.pass
      nesting: selectedMessage.nesting
    })


  @createForResponseMessage = (queuedMessage) ->
    pass = queuedMessage.pass.getForResponse()
    if pass?
      new this(queuedMessage.transmission, {
        pass
        nesting: queuedMessage.nesting
      })
    else
      @getNullQuery()



  constructor: (@transmission, opts = {}) ->
    {@pass, @nesting} = opts
    throw new Error "Missing nesting" unless @nesting?
    @passedLines = new FastSet()


  createNextQuery: ->
    Query.createNext(this)


  createQueryResponseMessage: (payload) ->
    @transmission.Message.createQueryResponse(this, payload)



  directionMatches: (direction) -> @pass.directionMatches(direction)


  type: 'query'

  communicationTypePriority: 0


  join: (comm) ->
    if this.pass.equals(comm.pass)
      Nesting.equalize [this.nesting, comm.nesting]
    return this


  getUpdatePrecedence: ->
    @updatePrecedence ?=
      Precedence.createUpdate(@pass)


  wasDelivered: ->
    @delivered or @passedLines.length > 0


  tryQueryChannelNode: (channelNode) ->
    @transmission.tryQueryChannelNode(this, channelNode)


  sendToLine: (line) ->
    @log line
    line.receiveQuery(this)
    return this


  getPassedLines: -> @passedLines


  addPassedLine: (line) ->
    @passedLines.add(line)
    return this


  _sendToNodePoint: (point) ->
    @log point
    existing = @transmission.getCommunicationFor('query', @pass, point)
    existing ?= @transmission.getCommunicationFor('message', @pass, point)
    existing ?= @transmission.getCommunicationFor('message', @pass.getNext(), point)
    if existing?
      existing.join(this)
      @delivered = yes
    else
      @transmission.addCommunicationFor(this, point)
      point.receiveQuery(this)
    return this


  resendFromNodePoint: (point, channelNode, connectionMessage) ->
    @nesting = connectionMessage.nesting
    point.resendQuery(this, channelNode)
    return this


  sendToNodeSource: (nodeSource) ->
    @_sendToNodePoint(nodeSource)


  sendToChannelNode: (node) ->
    @log node
    node.receiveQuery(this)
    return this


  sendToNode: (node) ->
    @log node
    node.routeQuery(this)
    return this


  sendFromNodeToNodeTarget: (node, nodeTarget) ->
    @enqueueForSourceNode(node)
    @_sendToNodePoint(nodeTarget)


  enqueueForSourceNode: (@sourceNode) ->
    @transmission.enqueueCommunication(this)
    return this


  getQueuePrecedence: ->
    @queuePrecedence ?=
      Precedence.createQueue(@pass, @communicationTypePriority, @nesting)


  respond: ->
    unless @wasDelivered()
      @log 'respond', @sourceNode
      @sourceNode.respondToQuery(this,
        @transmission.getPayloadFor(@sourceNode))
    return this
