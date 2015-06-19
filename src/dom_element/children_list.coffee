'use strict'


List = require '../nodes/list'


module.exports = class ChildrenList extends List

  constructor: (@element) ->


  set: (elementList) ->
    while (el = @element.lastChild)?
      @element.removeChild(el)

    for el in elementList
      @element.appendChild(el)

    return this


  setAt: (el, pos) ->
    @element.replaceChild(el, @getAt(pos))
    return this


  addAt: (el, pos) ->
    if pos == @getSize()
      @element.appendChild(el)
    else
      @element.insertBefore(el, @getAt(pos))
    return this


  removeAt: (pos) ->
    @element.removeChild(@getAt(pos))
    return this


  move: (fromPos, toPos) ->
    el = @getAt(fromPos)
    @removeAt(fromPos)
    @addAt(el, toPos)
    return this


  get: ->
    @element.children


  getAt: (pos) ->
    @element.children[pos]


  getSize: ->
    @element.children.length
