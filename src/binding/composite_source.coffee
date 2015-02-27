'use strict'


module.exports = class CompositeBindingSource

  constructor: (@sources, {@merge}) ->
    @target = null


  bindTarget: (target) ->
    @sources.forEach (source) => source.bindCompositeTarget(this)
    @target = target
    return this


  _getComposedSentMessages: (chain)->
    composedMessages = new Map()
    for source in @sources
      key = source.getSourceKey()
      message = source.getSentMessage(chain)
      return null if not message?
      composedMessages.set(key, message)
    return composedMessages


  receive: (message) ->
    if (messages = @_getComposedSentMessages(message.getChain()))
      @target.send(@merge(messages))
    return this
