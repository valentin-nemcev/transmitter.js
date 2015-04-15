'use strict'


module.exports = class MergingConnectionTarget

  constructor: (@sources) ->
    @sources.forEach (source, node) => source.setTarget(this)


  setTarget: (@target) -> return this


  receiveConnectionMessage: (message) ->
    @sources.forEach (source) -> source.receiveConnectionMessage(message)
    return this


  receiveMessage: (message) ->
    message.sendQueryForMerge(this)
    message.sendMergedTo(Array.from(@sources.keys()), @target)
    return this


  receiveQuery: (query) ->
    @sources.forEach (source, node) -> source.receiveQuery(query)
    return this
