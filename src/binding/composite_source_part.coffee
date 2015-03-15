'use strict'


module.exports = class CompositeBindingSourcePart

  constructor: (@source, params = {}) ->
    {@initiatesMerge} = params
    @compositeTarget = null


  bindCompositeTarget: (compositeTarget) ->
    @source.getMessageSender().bindTarget(this)
    @compositeTarget = compositeTarget
    return this


  getSourceKey: ->
    @source


  receive: (message) ->
    message.enquireForMerge(@compositeTarget) if @initiatesMerge
    @compositeTarget.receive(message)
    return this


  # getSentMessage: (messageChain) ->
  #   messageChain.getMessageFrom(@source)


  enquire: (query) ->
    @source.getMessageSender().enquire(query)
    return this
