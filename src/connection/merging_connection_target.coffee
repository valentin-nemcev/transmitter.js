'use strict'


module.exports = class MergingConnectionTarget

  constructor: (@sources) ->
    @target = null


  connectTarget: (target) ->
    @sources.forEach (source, node) => source.connectTarget(this)
    @target = target
    return this


  receiveMessage: (message) ->
    message.sendQueryForMerge(this)
    message.sendMergedTo(Array.from(@sources.keys()), @target)
    return this


  receiveQuery: (query) ->
    @sources.forEach (source, node) -> source.receiveQuery(query)
    return this
