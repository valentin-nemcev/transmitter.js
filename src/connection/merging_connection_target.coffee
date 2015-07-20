'use strict'


module.exports = class MergingConnectionTarget

  constructor: (@sources) ->
    @sources.forEach (source, node) => source.setTarget(this)


  inspect: ->
    '[' + @sources.keys().map( (s) -> s.inspect()).join(', ') + ']:'


  setTarget: (@target) -> return this


  connect: (message) ->
    @sources.forEach (source) -> source.connect(message)
    return this


  disconnect: (message) ->
    @sources.forEach (source) -> source.disconnect(message)
    return this


  receiveMessage: (message) ->
    message.sendMergedTo(this, @sources.keys(), @target)
    return this


  receiveQuery: (query) ->
    @sources.forEach (source, node) -> source.receiveQuery(query)
    return this
