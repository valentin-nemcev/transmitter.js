'use strict'


module.exports = class Binding

  constructor: ({@transform}) ->


  bindSourceTarget: (@source, @target) ->
    @source.bindTarget(this)
    @target.bindSource(this)
    return this


  receiveMessage: (message) ->
    message.sendTransformedTo(@transform, @target)
    return this


  receiveQuery: (query) ->
    @source.receiveQuery(query)
    return this
