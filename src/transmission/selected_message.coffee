'use strict'


FastMap = require 'collections/fast-map'
Precedence = require './precedence'


module.exports = class SelectedMessage

  inspect: ->
    [
      'SM'
      'P:' + @pass.inspect()
      @selectQuery?.inspect()
      @linesToMessages.values().map( (m) -> m.inspect() ).join(', ')
    ].join(' ')


  @getOrCreate = (nodeTarget, transmission, pass) ->
    selected = transmission.getCachedMessage(nodeTarget)
    if not selected? or pass.compare(selected.pass) > 0
      selected = new this(transmission, nodeTarget, {pass})
      transmission.setCachedMessage(nodeTarget, selected)
    return selected


  constructor: (@transmission, @nodeTarget, opts = {}) ->
    {@pass} = opts
    @linesToMessages = new FastMap()


  communicationTypePriority: 1


  getUpdatePrecedence: ->
    @precedence ?= Precedence.createUpdate(@pass, @communicationTypePriority)


  receiveMessageFrom: (message, line) ->
    @linesToMessages.set(line, message)
    @trySendToNodeTarget()
    return this


  _tryQueryForSelect: ->
    return @selectQuery if @selectQuery?

    existingQuery = @transmission.getCommunicationFor(@nodeTarget)

    if @transmission.Query.isForSelect(existingQuery, this)
      @selectQuery = existingQuery
    else
      @selectQuery = @transmission.Query.createForSelect(this)
      @selectQuery.sendToNodeTarget(@nodeTarget)

    return @selectQuery


  resend: -> @trySendToNodeTarget()


  trySendToNodeTarget: ->
    selectQuery = @_tryQueryForSelect()

    unless @_channelNodesUpdated()
      return this

    # TODO: Compare contents
    if @linesToMessages.length == selectQuery.getPassedLines().length
      @_selectForNodeTarget().sendToNodeTarget(@nodeTarget)


  _channelNodesUpdated: ->
    for node in @nodeTarget.getChannelNodes()
      return false unless @transmission.channelNodeUpdated(this, node)
    return true


  _selectForNodeTarget: ->
    # TODO: refactor
    messages = @linesToMessages.values().sorted (a, b) ->
      -1 * a.getSelectPrecedence().compare(b.getSelectPrecedence())
    @transmission.log @nodeTarget, messages...
    return messages[0]
