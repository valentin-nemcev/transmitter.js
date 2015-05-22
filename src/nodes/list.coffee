'use strict'


RelayNode = require './relay_node'
ListPayload = require '../payloads/list'


module.exports = class List extends RelayNode

  createResponsePayload: ->
    ListPayload.create(this)


  createRelayPayload: ->
    ListPayload.create(this)


  createOriginPayload: ->
    ListPayload.create(this)


  createUpdatePayload: (value) ->
    ListPayload.createFromValue(value)


  constructor: ->
    @list = []


  setValue: (list) ->
    @list.length = 0
    @list.push list...
    this


  get: ->
    @list.slice()
