'use strict'


{inspect} = require 'util'

FastMap = require 'collections/fast-map'
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
    @_sendQueryToForChannelNode(channelNode)
    @_sendMessage()


  _ensureQuerySent: ->
    @query ?= @_sendQuery()
    return this


  _sendQuery: ->
    query = @transmission.Query.createNext(this)

    nodeTarget = @node.getNodeTarget()
    nodeTarget.getChannelNodesFor(query).forEach (channelNode) =>
      if query.tryQueryChannelNode(channelNode)
        nodeTarget.receiveQueryForChannelNode(query, channelNode)

    query.tryEnqueue(@node)


  _sendQueryToForChannelNode: (channelNode) ->
    @node.getNodeTarget().receiveQueryForChannelNode(@query, channelNode)
    return this


  _sendMessage: ->
    unless @query.areAllChannelNodesUpdated()
      return this

    @transmission.log @node, @linesToMessages.entries()..., @initialMessage
    @transmission.log @node, @query, @query.getPassedLines().toArray()...
    # TODO: Compare contents
    if @linesToMessages.length == @query.getPassedLines().length
      @_trySendSelected()
    return this


  _trySendSelected: ->
    return this if @selectedMessage?
    # TODO: refactor
    messages = @linesToMessages.values()
    messages.push @initialMessage if @initialMessage?
    sorted = messages.sorted (a, b) ->
      -1 * a.getSelectPrecedence().compare(b.getSelectPrecedence())
    @transmission.log this, @node
    # @selectedMessage should be set before it is sent to prevent loops
    @selectedMessage = sorted[0]
    if @selectedMessage?
      @selectedMessage.sendToNode(@node)
    return this
