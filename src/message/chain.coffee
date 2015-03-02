'use strict'


module.exports = class MessageChain

  constructor: ({@queryQueue})->
    @sendersToMessages = new Map()


  addMessageFrom: (message, sender) ->
    @sendersToMessages.set(sender, message)
    return this


  getMessageFrom: (sender) ->
    @sendersToMessages.get(sender)


  addToQueryQueue: (sender) ->
    @queryQueue.addSenderWithChain(sender, this)
    return this
