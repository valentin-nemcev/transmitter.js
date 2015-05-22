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


  set: (list) ->
    @list.length = 0
    @list.push list...
    return this


  setAt: (el, pos) ->
    @list[pos] = el
    return this


  addAt: (el, pos) ->
    if pos == @list.length
      @list.push el
    else
      @list.splice(pos, 0, el)
    return this


  removeAt: (pos) ->
    @list.splice(pos, 1)
    return this


  move: (fromPos, toPos) ->
    @list.splice(toPos, 0, @list.splice(fromPos, 1)[0])
    return this


  get: ->
    @list.slice()


  getAt: (pos) ->
    @list[pos]


  getSize: ->
    @list.length
