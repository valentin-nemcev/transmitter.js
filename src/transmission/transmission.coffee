'use strict'

Query = require './query'
Message = require './message'


module.exports = class Transmission

  constructor: ->
    @sendersToMessages = new Map()
    @enqueriedNodes = []


  createMessage: (payload) ->
    new Message(this, payload)


  createQuery: ->
    return new Query({transmission: this})


  addMessageFrom: (message, sender) ->
    @sendersToMessages.set(sender, message)
    return this


  getMessageFrom: (sender) ->
    @sendersToMessages.get(sender)


  addQueryTo: (node) ->
    @enqueriedNodes.push node
    return this


  getEnqueriedNodes: ->
    @enqueriedNodes
