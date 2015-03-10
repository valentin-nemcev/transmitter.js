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
    message.enquireForMerge(@compositeTarget) if @initiatesMerge
    @compositeTarget.receive(message)
    return this


  getSentMessage: (messageChain) ->
    messageChain.getMessageFrom(@source)


  enquire: (messageChain) ->
    @source.enquire(messageChain)
    return this
