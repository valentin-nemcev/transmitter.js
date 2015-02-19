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


  send: (message) ->
    @lastMessage = message
    @compositeTarget.sendMerged() if @initiatesMerge
    return this


  enquire: ->
    return @lastMessage
