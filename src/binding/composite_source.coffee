'use strict'


module.exports = class CompositeBindingSource

  constructor: (@sources, {@merge}) ->
    @target = null


  bindTarget: (target) ->
    @sources.forEach (source, node) => source.bindTarget(this)
    @target = target
    return this


  receiveMessage: (message) ->
    message.sendMergedTo(Array.from(@sources.keys()), @target)
    return this


  receiveQuery: (query) ->
    @sources.forEach (source, node) -> source.receiveQuery(query)
    return this
