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
    @trySendToNodeTarget()
    return this


  joinInitialMessage: (message) ->
    throw new Error "Can send only one initial message" if @initialMessage?
    @initialMessage = message
    @trySendToNodeTarget()
    return this


  joinQuery: (query) ->
    @trySendToNodeTarget()


  joinMessageForResponse: (message) ->
    @trySendToNodeTarget()


  _tryQuery: ->
    @query ?= do =>
      query = @transmission.getCommunicationFor('query', @pass, @nodeTarget)
      unless query?
        query = @transmission.Query.createNext(this)
          .sendToNodeTarget(@nodeTarget)
      query.join(this)

    return this


  joinConnectionMessage: (channelNode) ->
    @trySendToNodeTarget()


  trySendToNodeTarget: ->
    @_tryQuery()

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
