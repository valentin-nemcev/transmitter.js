'use strict'


{inspect} = require 'util'

FastMap = require 'collections/fast-map'
Set = require 'collections/set'
Precedence = require './precedence'
NodePointTransmissionHub = require './node_point_transmission_hub'


module.exports = class JointMessage

  inspect: ->
    [
      'SM'
      inspect @pass
      @query?.inspect()
      ','
      @linesToMessages.values().map(inspect).join(', ')
    ].join(' ')


  @getOrCreate = (comm, {node, nodeTarget, nodeSource}) ->
    {transmission, pass} = comm
    node ?= nodeTarget?.node ? nodeSource?.node

    selected = transmission.getCommunicationFor(pass, node)
    unless selected?
      selected = new this(transmission, node, {pass})
      transmission.addCommunicationForAndEnqueue(selected, node)
    return selected


  constructor: (@transmission, @node, opts = {}) ->
    {@pass} = opts
    @linesToMessages = new FastMap()


  joinMessageFrom: (message, line) ->
    @transmission.log line, message
    if (prev = @linesToMessages.get(line))?
      throw new Error "Already received message from #{inspect line}"
    @linesToMessages.set(line, message)
    @_ensureQuerySent()
    @_selectAndSendMessageIfReady()


  joinQueryFrom: (query, line) ->
    @_ensureQuerySent()


  originateQuery: ->
    @_ensureQuerySent()


  joinTargetConnectionMessage: (channelNode) ->
    @_ensureQuerySent()
    @_sendQueryForChannelNode(channelNode)
    @_selectAndSendMessageIfReady()


  joinSourceConnectionMessage: (channelNode) ->
    @messageHub?.sendForChannelNode(channelNode)
    return this


  joinPrecedingMessage: (@precedingMessage) ->
    @_ensureQuerySent()


  originateMessage: (payload) ->
    if @message?
        throw new Error "Message already originated at #{inspect @node}. " \
          + "Previous: #{inspect @message}"
    payload = @node.processPayload(payload)
    # payload.setPriority(1)
    message = @transmission.Message
      .createNext(this, payload)
      .setPriority(1)
    @_sendMessage(message)
    return this


  _ensureQuerySent: ->
    return this if @query?
    # This method is reentrant, so assign @query before sending
    @query = @transmission.Query.createNext(this)
    @queryHub = new NodePointTransmissionHub(@query, @node.getNodeTarget())
    @queryHub.sendForAll()

    return this


  _sendQueryForChannelNode: (channelNode) ->
    @queryHub.sendForChannelNode(channelNode)
    return this


  _selectAndSendMessageIfReady: ->
    unless @queryHub.areAllChannelNodesUpdated()
      return this

    @transmission.log @node, @linesToMessages.entries()...
    @transmission.log @node, @query, @query.getPassedLines().toArray()...
    # TODO: Compare contents
    unless @linesToMessages.length == @query.getPassedLines().length
      return this

    newSelectedMessage = @_selectMessage()
    if @selectedMessage?
      @_assertSelectedMessage(newSelectedMessage)
      return this

    return this unless newSelectedMessage?

    @selectedMessage = newSelectedMessage
    if @message?
      @_assertMessage(newSelectedMessage)
      return this

    @_sendMessage(@_processMessage(newSelectedMessage))
    return this


  _assertSelectedMessage: (newSelectedMessage) ->
    if @selectedMessage != newSelectedMessage
      throw new Error "Message already selected at #{inspect @node}. " \
        + "Previous: #{inspect @selectedMessage}, " \
        + "current: #{inspect newSelectedMessage}"
    return this


  _assertMessage: (message) ->
    if @message != message \
      and message.getSelectPrecedence()
        .compare(@message.getSelectPrecedence()) >= 0
          throw new Error "Message already sent at #{inspect @node}. " \
            + "Previous: #{inspect @message}, " \
            + "current: #{inspect message}"
    return this


  _selectMessage: ->
    # TODO: Add checks for more than one message with precedence of 1
    messages = @linesToMessages.values()
    sorted = messages.sorted (a, b) ->
      -1 * a.getSelectPrecedence().compare(b.getSelectPrecedence())
    return sorted[0]


  _processMessage: (prevMessage) ->
    @transmission.log prevMessage, @node
    prevPayload = prevMessage.payload
    nextPayload = @node.processPayload(prevPayload)
    # nextPayload.setPriority(prevPayload.getPriority())
    @transmission.Message
      .createNext(this, nextPayload)
      .setPriority(prevMessage.getPriority())


  readyToRespond: ->
    @query? and not @message? and not @query.wasDelivered() \
      and @queryHub.areAllChannelNodesUpdated()


  respond: ->
    @transmission.log @query, 'respond', @node
    prevPayload = @precedingMessage?.payload
    nextPayload = @node.createResponsePayload(prevPayload)
    # nextPayload.setPriority(prevPayload?.getPriority() ? 0)
    nextMessage = @transmission.Message
      .createQueryResponse(this, nextPayload)
      .setPriority(@precedingMessage?.getPriority() ? 0)
    @_sendMessage(nextMessage)


  _sendMessage: (message) ->
    @transmission.log this, @node
    throw new Error "Can't send message twice" if @message?
    # This method is reentrant, so assign @message before sending
    @message = message
    @transmission.log @message, @node.getNodeSource()

    @message.sourceNode = @node
    @_joinMessageToSucceeding()
    @messageHub = new NodePointTransmissionHub(@message, @node.getNodeSource())
    @messageHub.sendForAll()
    return this


  _joinMessageToSucceeding: ->
    responsePass = @pass.getForResponse()
    if responsePass?
      JointMessage.getOrCreate({@transmission, pass: responsePass}, {@node})
        .joinPrecedingMessage(@message)

