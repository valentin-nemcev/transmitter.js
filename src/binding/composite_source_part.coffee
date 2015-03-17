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


  receive: (message) ->
    message.enquireForMerge(@compositeTarget) if @initiatesMerge
    @compositeTarget.receive(message)
    return this


  enquire: (query) ->
    @source.enquire(query)
    return this
