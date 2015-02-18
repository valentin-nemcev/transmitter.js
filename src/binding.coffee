'use strict'


module.exports = class Binding

  constructor: ({@transform}) ->


  bindSourceTarget: (@source, @target) ->
    @source.bindTarget(this)
    return this


  send: (message) ->
    @target.send(@transform.call(null, message))
    return this
