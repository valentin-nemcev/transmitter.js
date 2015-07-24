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


  @create = (transmission, opts) => new this(transmission, opts)


  constructor: (@transmission, opts = {}) ->
    {@pass} = opts
    @linesToMessages = new FastMap()


  communicationTypePriority: 1


  getUpdatePrecedence: ->
    @precedence ?= Precedence.createUpdate(@pass, @communicationTypePriority)


  receiveMessageFrom: (message, line) ->
    @linesToMessages.set(line, message)
    return this


  _tryQueryForSelect: (nodeTarget) ->
    return @selectQuery if @selectQuery?

    existingQuery = @transmission.getCommunicationFor(nodeTarget)

    if @transmission.Query.isForSelect(existingQuery, this)
      @selectQuery = existingQuery
    else
      @selectQuery = @transmission.Query.createForSelect(this)
      @selectQuery.sendToNodeTarget(nodeTarget)

    return @selectQuery


  resendToNodePoint: (nodePoint) -> @sendToNodeTarget(nodePoint)


  sendToNodeTarget: (nodeTarget) ->
    selectQuery = @_tryQueryForSelect(nodeTarget)

    unless @_channelNodesUpdated(nodeTarget.getChannelNodes())
      return this

    # TODO: Compare contents
    if @linesToMessages.length == selectQuery.getPassedLines().length
      message = @_selectForNodeTarget(nodeTarget)
      message.sendToNodeTarget(nodeTarget)


  _channelNodesUpdated: (channelNodes) ->
    for node in channelNodes
      return false unless @transmission.channelNodeUpdated(this, node)
    return true


  _selectForNodeTarget: (nodeTarget) ->
    # TODO: refactor
    messages = @linesToMessages.values().sorted (a, b) ->
      -1 * a.getSelectPrecedence().compare(b.getSelectPrecedence())
    @transmission.log nodeTarget, messages...
    return messages[0]
