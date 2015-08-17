'use strict'


{inspect} = require 'util'


module.exports = class MergingConnectionTarget

  inspect: ->
    '[' + @sources.keys().map(inspect).join(', ') + ']:'


  constructor: (@sources) ->
    @sources.forEach (source, node) => source.setTarget(this)


  getSourceNodes: -> @sources.keys()


  setTarget: (@target) -> return this


  connect: (message) ->
    @sources.forEach (source) -> source.connect(message)
    return this


  disconnect: (message) ->
    @sources.forEach (source) -> source.disconnect(message)
    return this


  receiveMessage: (message) ->
    message.sendMergedTo(this, @target)
    return this


  sendMessage: (message) ->
    @target.receiveMessage(message)
    return this


  receiveQuery: (query) ->
    @sources.forEach (source, node) -> source.receiveQuery(query)
    return this
