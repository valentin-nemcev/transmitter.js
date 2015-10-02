'use strict'


{inspect} = require 'util'

noop = require '../payloads/noop'


module.exports = class MergingConnectionTarget

  inspect: ->
    '[' + @sources.keys().map(inspect).join(', ') + ']:'


  constructor: (@sources, opts = {}) ->
    {@prioritiesShouldMatch} = opts
    @sources.forEach (source, node) => source.setTarget(this)


  getSourceNodes: -> @sources.keys()


  setTarget: (@target) -> return this


  connect: (message) ->
    @sources.forEach (source) -> source.connect(message)
    message.joinMergedMessage(this)
    return this


  disconnect: (message) ->
    @sources.forEach (source) -> source.disconnect(message)
    return this


  getPlaceholderPayload: -> noop()


  receiveMessage: (message) ->
    message.joinMergedMessage(this)
    return this


  sendMessage: (message) ->
    @target.receiveMessage(message)
    return this


  sendQuery: (query) ->
    @sources.forEach (source, node) -> source.receiveQuery(query)
    return this


  receiveQuery: (query) ->
    query.joinMergedMessage(this)
    return this
