'use strict'


module.exports = class CompositeBindingSourcePart

  constructor: (@source, params = {}) ->
    {@initiatesMerge} = params
    @compositeTarget = null


  bindCompositeTarget: (compositeTarget) ->
    @source.bindTarget(this)
    @compositeTarget = compositeTarget
    return this


  getSourceKey: ->
    @source


  send: (message) ->
    @compositeTarget.sendMerged(message.getChain())
    return this


  getSentMessage: (messageChain) ->
    messageChain.getMessageSentFrom(@source)
