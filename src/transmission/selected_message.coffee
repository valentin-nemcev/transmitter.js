'use strict'


{inspect} = require 'util'

FastMap = require 'collections/fast-map'
Set = require 'collections/set'
Precedence = require './precedence'


module.exports = class SelectedMessage

  inspect: ->
    [
      'SM'
      inspect @pass
      @query?.inspect()
      ','
      @linesToMessages.values().map(inspect).join(', ')
    ].join(' ')


  @joinMessageForResponse = (message, {node, nodeTarget}) ->
    {transmission, pass} = message
    nodeTarget ?= node.getNodeTarget()
    node ?= nodeTarget.node
    responsePass = pass.getForResponse()
    if responsePass?
      @getOrCreate({transmission, pass: responsePass}, node)
        .joinMessageForResponse(message)
    return this


  @getOrCreate = (comm, {node, nodeTarget}) ->
    {transmission, pass} = comm
    nodeTarget ?= node.getNodeTarget()
    node ?= nodeTarget.node
    selected = transmission.getCommunicationFor('message', pass, node)
    unless selected?
      selected = new this(transmission, node, {pass})
      transmission.addCommunicationFor(selected, node)
    return selected


  constructor: (@transmission, @node, opts = {}) ->
    {@pass} = opts
    @linesToMessages = new FastMap()


  type: 'message'


  join: (comm) ->
    return this


  joinMessageFrom: (message, line) ->
    @transmission.log line, message
    if (prev = @linesToMessages.get(line))?
      throw new Error "Already received message from #{inspect line}"
    @linesToMessages.set(line, message)
    @_ensureQuerySent()
    @_sendMessage()


  joinInitialMessage: (message) ->
    throw new Error "Can send only one initial message" if @initialMessage?
    @initialMessage = message
    @_ensureQuerySent()
    @_sendMessage()


  joinQuery: (query) ->
    @_ensureQuerySent()


  joinMessageForResponse: (message) ->
    @_ensureQuerySent()


  joinConnectionMessage: (channelNode) ->
    @_ensureQuerySent()
    @_sendQueryForChannelNode(channelNode)
    @_sendMessage()


  _queryWasSent: -> @query?


  _ensureQuerySent: ->
    @query ?= @_sendQuery()
    return this


  _sendQuery: ->
    query = @transmission.Query.createNext(this)
    @updatedChannelNodes = new Set()

    nodeTarget = @node.getNodeTarget()
    nodeTarget.getChannelNodesFor(query).forEach (channelNode) =>
      if query.tryQueryChannelNode(channelNode)
        @updatedChannelNodes.add(channelNode)
        nodeTarget.receiveQueryForChannelNode(query, channelNode)

    query.tryEnqueue(@node)


  _sendQueryForChannelNode: (channelNode) ->
    unless @updatedChannelNodes.has(channelNode)
      @updatedChannelNodes.add(channelNode)
      @node.getNodeTarget().receiveQueryForChannelNode(@query, channelNode)
    return this


  _sendMessage: ->
    unless @query.areAllChannelNodesUpdated()
      return this

    @transmission.log @node, @linesToMessages.entries()..., @initialMessage
    @transmission.log @node, @query, @query.getPassedLines().toArray()...
    # TODO: Compare contents
    if @linesToMessages.length == @query.getPassedLines().length
      @_trySendOutgoing()
    return this


  _trySendOutgoing: ->
    # return this if @outgoingMessage?
    @transmission.log this, @node
    newOutgoingMessage = @_selectMessage()
    if @outgoingMessage? and @outgoingMessage != newOutgoingMessage
      throw new Error "Outgoing message already sent at #{inspect @node}. " \
        + "Previous: #{inspect @outgoingMessage}, " \
        + "current: #{inspect newOutgoingMessage}"
    # @outgoingMessage should be set before it is sent to prevent loops
    if not @outgoingMessage? and newOutgoingMessage?
      @outgoingMessage = newOutgoingMessage
      @outgoingMessage.sendToNode(@node)
    return this


  _selectMessage: ->
    # TODO: refactor
    messages = @linesToMessages.values()
    messages.push @initialMessage if @initialMessage?
    sorted = messages.sorted (a, b) ->
      -1 * a.getSelectPrecedence().compare(b.getSelectPrecedence())
    return sorted[0]
