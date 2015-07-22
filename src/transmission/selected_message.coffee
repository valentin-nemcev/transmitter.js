'use strict'


FastMap = require 'collections/fast-map'


module.exports = class SelectedMessage

  @create = (transmission, opts) => new this(transmission, opts)


  constructor: (@transmission, opts = {}) ->
    {@precedence} = opts
    @linesToMessages = new FastMap()


  communicationTypeOrder: 1


  getPrecedence: ->
    [@precedence.level, @communicationTypeOrder]


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
      message = @_selectForNodeTarget()
      message.sendToNodeTarget(nodeTarget)


  _channelNodesUpdated: (channelNodes) ->
    for node in channelNodes
      return false unless @transmission.channelNodeUpdated(this, node)
    return true


  _selectForNodeTarget: ->
    # TODO: refactor
    messages = @linesToMessages.values().sorted (a, b) ->
      -1 * Object.compare(a.precedence.level, b.precedence.level)
    @transmission.log 'choose', messages...
    return messages[0]
