'use strict'

Query = require '../query'


module.exports = class MessageChain

  constructor: ()->
    @sendersToMessages = new Map()


  createQuery: ->
    return new Query({messageChain: this})


  addMessageFrom: (message, sender) ->
    @sendersToMessages.set(sender, message)
    return this


  getMessageFrom: (sender) ->
    @sendersToMessages.get(sender)


  addQueryTo: (node) ->
    return this
