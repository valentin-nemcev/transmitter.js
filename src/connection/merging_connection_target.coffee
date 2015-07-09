'use strict'


module.exports = class MergingConnectionTarget

  constructor: (@sources) ->
    @sources.forEach (source, node) => source.setTarget(this)


  inspect: ->
    '[' + @sources.keys().map( (s) -> s.inspect()).join(', ') + ']:'


  setTarget: (@target) -> return this


  receiveConnectionMessage: (message) ->
    @sources.forEach (source) -> source.receiveConnectionMessage(message)
    return this


  receiveMessage: (message) ->
    message.sendMergedTo(this, @sources.keys(), @target)
    return this


  receiveQuery: (query) ->
    @sources.forEach (source, node) -> source.receiveQuery(query)
    return this
