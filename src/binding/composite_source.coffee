'use strict'


module.exports = class CompositeBindingSource

  constructor: (@sources) ->
    @target = null


  bindTarget: (target) ->
    @sources.forEach (source) => source.bindCompositeTarget(this)
    @target = target
    return this


  sendMerged: ->
    composedMessage = new Map()
    @sources.forEach (source) ->
      composedMessage.set(source.getSourceKey(), source.enquire())

    @target.send(composedMessage)
    return this
