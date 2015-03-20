'use strict'


module.exports = class Binding

  constructor: ({@transform}) ->


  bindSourceTarget: (@source, @target) ->
    @source.bindTarget(this)
    @target.bindSource(this)
    return this


  receiveMessage: (message) ->
    @target.receiveMessage(message.copyWithTransformedPayload(@transform))
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
