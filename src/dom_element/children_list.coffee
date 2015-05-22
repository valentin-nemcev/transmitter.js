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


  get: ->
    @element.children
