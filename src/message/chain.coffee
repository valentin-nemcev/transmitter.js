'use strict'


module.exports = class MessageChain

  constructor: ()->
    @sendersToMessages = new Map()


  addMessageFrom: (message, sender) ->
    @sendersToMessages.set(sender, message)
    return this


  getMessageFrom: (sender) ->
    @sendersToMessages.get(sender)


  addQueryTo: (node) ->
    return this
