'use strict'


module.exports = class Binding

  constructor: ({@transform}) ->


  bindSourceTarget: (@source, @target) ->
    @source.bindTarget(this)
    @target.bindSource(this)
    return this


  send: (message) ->
    @target.send(message.copyWithTransformedPayload(@transform))
    return this


  enquire: (query) ->
    @source.enquire(query)
    return this
