'use strict'


module.exports = class CompositeBindingSource

  constructor: (@sources, {@merge}) ->
    @target = null


  bindTarget: (target) ->
    @sources.forEach (source) => source.bindCompositeTarget(this)
    @target = target
    return this


  _getComposedSentMessages: (transmission)->
    composedMessages = new Map()
    for source in @sources
      key = source.getSourceKey()
      message = source.getSentMessage(transmission)
      return null if not message?
      composedMessages.set(key, message)
    return composedMessages


  sendMerged: (transmission) ->
    if (messages = @_getComposedSentMessages(transmission))
      @target.send(@merge(messages))
    return this


  receive: (message) ->
    sourceKeys = @sources.map (source) -> source.getSourceKey()
    message.sendMergedTo(sourceKeys, @target)
    return this


  enquire: (query) ->
    for source in @sources
      source.enquire(query)
    return this
