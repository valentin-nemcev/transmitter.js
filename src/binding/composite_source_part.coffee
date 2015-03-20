'use strict'


module.exports = class CompositeBindingSourcePart

  constructor: (@sourceNode, @source, params = {}) ->
    {@initiatesMerge} = params
    @compositeTarget = null


  bindCompositeTarget: (compositeTarget) ->
    @source.bindTarget(this)
    @compositeTarget = compositeTarget
    return this


  getSourceKey: ->
    @sourceNode


  receiveMessage: (message) ->
    message.sendQueryForMerge(@compositeTarget) if @initiatesMerge
    @compositeTarget.receiveMessage(message)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
