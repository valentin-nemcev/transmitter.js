'use strict'


{inspect} = require 'util'

FastMap = require 'collections/fast-map'
Set = require 'collections/set'
Precedence = require './precedence'


module.exports = class JointMessage

  inspect: ->
    [
      'SM'
      inspect @pass
      @query?.inspect()
      ','
      @linesToMessages.values().map(inspect).join(', ')
    ].join(' ')


  @getOrCreate = (comm, {node, nodeTarget}) ->
    {transmission, pass} = comm
    nodeTarget ?= node.getNodeTarget()
    node ?= nodeTarget.node

    selected = transmission.getCommunicationFor(pass, node)
    unless selected?
      selected = new this(transmission, node, {pass})
      transmission.addCommunicationFor(selected, node)
    return selected


  constructor: (@transmission, @node, opts = {}) ->
    {@pass} = opts
    @linesToMessages = new FastMap()


  join: (comm) ->
    return this


  joinMessageFrom: (message, line) ->
    @transmission.log line, message
    if (prev = @linesToMessages.get(line))?
      throw new Error "Already received message from #{inspect line}"
    @linesToMessages.set(line, message)
    @_ensureQuerySent()
    @_selectAndSendOutgoingIfReady()


  joinQuery: (query) ->
    @_ensureQuerySent()
    return this


  joinMessageForResponse: (@prevMessage) ->
    @_ensureQuerySent()


  joinTargetConnectionMessage: (channelNode) ->
    @_ensureQuerySent()
    @_sendQueryForChannelNode(channelNode)
    @_selectAndSendOutgoingIfReady()


  joinSourceConnectionMessage: (channelNode) ->
    @outgoingMessage?.sendForChannelNode(channelNode)
    return this


  _queryWasSent: -> @query?


  _ensureQuerySent: ->
    return this if @query?
    @query = @transmission.Query.createNext(this)

    @updatedChannelNodes = new Set()

    nodeTarget = @node.getNodeTarget()
    nodeTarget.getChannelNodesFor(@query).forEach (channelNode) =>
      if @query.tryQueryChannelNode(channelNode)
        @updatedChannelNodes.add(channelNode)
        nodeTarget.receiveQueryForChannelNode(@query, channelNode)

    return this


  originateResponseMessage: ->
    @transmission.log @query, 'respond', @node
    prevPayload = @prevMessage?.payload
    payload = @node.createResponsePayload(prevPayload)
    @_sendOutgoing(
      @transmission.Message.createQueryResponse(this, payload))

  readyToRespond: ->
    @query? and not @outgoingMessage? and not @query.wasDelivered() \
      and @areAllChannelNodesUpdated()


  respond: -> @originateResponseMessage()


  areAllChannelNodesUpdated: ->
    for node in @node.getNodeTarget().getChannelNodesFor(@query)
      return false unless @transmission.channelNodeUpdated(@query, node)
    return true


  _sendQueryForChannelNode: (channelNode) ->
    unless @updatedChannelNodes.has(channelNode)
      @updatedChannelNodes.add(channelNode)
      @node.getNodeTarget().receiveQueryForChannelNode(@query, channelNode)
    return this


  _selectAndSendOutgoingIfReady: ->
    unless @areAllChannelNodesUpdated()
      return this

    @transmission.log @node, @linesToMessages.entries()...
    @transmission.log @node, @query, @query.getPassedLines().toArray()...
    # TODO: Compare contents
    if @linesToMessages.length == @query.getPassedLines().length
      newJointMessage = @_selectMessage()
      if @selectedMessage? and @selectedMessage != newJointMessage
        throw new Error "Message already selected at #{inspect @node}. " \
          + "Previous: #{inspect @selectedMessage}, " \
          + "current: #{inspect newJointMessage}"
      if newJointMessage? and @selectedMessage != newJointMessage
        @selectedMessage = newJointMessage
        if @outgoingMessage?
          if @outgoingMessage != newJointMessage \
            and newJointMessage.getSelectPrecedence()
              .compare(@outgoingMessage.getSelectPrecedence()) >= 0
                throw new Error "Message already sent at #{inspect @node}. " \
                  + "Previous: #{inspect @outgoingMessage}, " \
                  + "current: #{inspect newJointMessage}"
        else
          @_sendOutgoing(@_relayMessage(newJointMessage))
    return this


  _relayMessage: (prevMessage) ->
    @transmission.log prevMessage, @node
    payload = @node.processPayload(prevMessage.payload)
    @transmission.Message.createNext(this, payload)


  _sendOutgoing: (newOutgoingMessage) ->
    @transmission.log this, @node
    # This method is reentrant, so assign @outgoingMessage before sending
    @outgoingMessage = newOutgoingMessage
    @transmission.log @outgoingMessage, @node.getNodeSource()

    @outgoingMessage.sourceNode = @node
    responsePass = @pass.getForResponse()
    if responsePass?
      JointMessage.getOrCreate({@transmission, pass: responsePass}, {@node})
        .joinMessageForResponse(@outgoingMessage)

    @outgoingMessage.send(@node.getNodeSource())
    return this


  originateMessage: (payload) ->
    if @outgoingMessage?
        throw new Error "Message already originated at #{inspect @node}. " \
          + "Previous: #{inspect @outgoingMessage}"
    payload = @node.processPayload(payload)
    @_sendOutgoing(@transmission.Message.createNext(this, payload))
    return this


  _selectMessage: ->
    # TODO: refactor
    messages = @linesToMessages.values()
    sorted = messages.sorted (a, b) ->
      -1 * a.getSelectPrecedence().compare(b.getSelectPrecedence())
    return sorted[0]
