'use strict'


module.exports = class CompositeBindingSource

  constructor: (@sources, {@merge}) ->
    @target = null


  bindTarget: (target) ->
    @sources.forEach (source) => source.bindCompositeTarget(this)
    @target = target
    return this


  receiveMessage: (message) ->
    sourceKeys = @sources.map (source) -> source.getSourceKey()
    message.sendMergedTo(sourceKeys, @target)
    return this


  receiveQuery: (query) ->
    for source in @sources
      source.receiveQuery(query)
    return this
