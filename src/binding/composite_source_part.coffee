'use strict'


module.exports = class CompositeBindingSourcePart

  constructor: (@sourceNode, @source, params = {}) ->
    {@queryForMergeWith} = params
    @compositeTarget = null


  bindCompositeTarget: (compositeTarget) ->
    @source.bindTarget(this)
    @compositeTarget = compositeTarget
    return this


  getSourceKey: ->
    @sourceNode


  receiveMessage: (message) ->
    if @queryForMergeWith?
      message.sendQueryForMerge(@compositeTarget, @queryForMergeWith)
    @compositeTarget.receiveMessage(message)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
