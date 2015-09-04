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


  @joinMessageForResponse = (message, nodeTarget) ->
    {transmission, pass} = message
    responsePass = pass.getForResponse()
    if responsePass?
      @getOrCreate({transmission, pass: responsePass}, nodeTarget)
        .joinMessageForResponse(message)
    return this


  @getOrCreate = (comm, nodeTarget) ->
    {transmission, pass} = comm
    selected = transmission.getCommunicationFor('message', pass, nodeTarget)
    unless selected?
      selected = new this(transmission, nodeTarget, {pass})
      transmission.addCommunicationFor(selected, nodeTarget)
    return selected


  constructor: (@transmission, @nodeTarget, opts = {}) ->
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

    @nodeTarget.getChannelNodesFor(query).forEach (channelNode) =>
      if query.tryQueryChannelNode(channelNode)
        @nodeTarget.receiveQueryForChannelNode(query, channelNode)

    query.tryEnqueue(@nodeTarget)


  _sendQueryToForChannelNode: (channelNode) ->
    @nodeTarget.receiveQueryForChannelNode(@query, channelNode)
    return this


  _sendMessage: ->
    unless @query.areAllChannelNodesUpdated()
      return this

    @transmission.log @nodeTarget, @linesToMessages.entries()..., @initialMessage
    @transmission.log @nodeTarget, @query, @query.getPassedLines().toArray()...
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
    @transmission.log this, @nodeTarget
    # @selectedMessage should be set before it is sent to prevent loops
    @selectedMessage = sorted[0]
    if @selectedMessage?
      @nodeTarget.receiveMessage(@selectedMessage)
    return this
