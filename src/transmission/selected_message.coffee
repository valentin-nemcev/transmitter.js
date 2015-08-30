'use strict'


{inspect} = require 'util'

FastMap = require 'collections/fast-map'
Precedence = require './precedence'


module.exports = class SelectedMessage

  inspect: ->
    [
      'SM'
      inspect @pass
      @selectQuery?.inspect()
      ','
      @linesToMessages.values().map(inspect).join(', ')
    ].join(' ')


  @getOrCreate = (message, nodeTarget) ->
    {transmission, pass} = message
    selected = transmission.getCachedMessage(nodeTarget)
    unless (selected? and pass.equals(selected.pass))
      selected = new this(transmission, nodeTarget, {pass})
      transmission.setCachedMessage(nodeTarget, selected)
    return selected


  constructor: (@transmission, @nodeTarget, opts = {}) ->
    {@pass} = opts
    @linesToMessages = new FastMap()


  getUpdatePrecedence: ->
    @precedence ?= Precedence.createUpdate(@pass)


  receiveMessageFrom: (message, line) ->
    @linesToMessages.set(line, message)
    @trySendToNodeTarget()
    return this


  receiveInitialMessage: (message) ->
    throw new Error "Can send only one initial message" if @initialMessage?
    @initialMessage = message
    @trySendToNodeTarget()
    return this


  _tryQueryForSelect: ->
    @selectQuery ?=
      @transmission.getCommunicationFor('query', @pass, @nodeTarget)

    @selectQuery ?= @transmission.Query.createForSelect(this)
      .sendFromNodeToNodeTarget(@nodeTarget.node, @nodeTarget)

    return this


  resendFromNodePoint: -> @trySendToNodeTarget()


  trySendToNodeTarget: ->
    @_tryQueryForSelect()

    unless @_channelNodesUpdated()
      return this

    @transmission.log @nodeTarget, @linesToMessages.entries()..., @initialMessage
    @transmission.log @nodeTarget, @selectQuery, @selectQuery.getPassedLines().toArray()...
    # TODO: Compare contents
    if @linesToMessages.length == @selectQuery.getPassedLines().length
      @_trySendSelected()
    return this


  _channelNodesUpdated: ->
    for node in @nodeTarget.getChannelNodesFor(@selectQuery)
      return false unless @transmission.channelNodeUpdated(this, node)
    return true


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
    @nodeTarget.receiveMessage(@selectedMessage)
    return this
