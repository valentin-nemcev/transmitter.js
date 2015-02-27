'use strict'


module.exports = class MessageChain

  constructor: ->
    @sendersToMessages = new Map()


  messageSent: (message, from: sender) ->
    @sendersToMessages.set(sender, message)
    return this


  getMessageSentFrom: (sender) ->
    @sendersToMessages.get(sender)
