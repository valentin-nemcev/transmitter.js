'use strict'


{inspect} = require 'util'


module.exports = class ListPayload

  constructor: (@list) ->


  inspect: -> "list: #{inspect @value}"


  map: (map) ->
    return new ListPayload(@list.map(map))


  deliverToTargetNode: (targetNode) ->
    targetNode.receiveValue(@list)
    return this


  deliver: (targetNode) ->
    targetNode.setValue(@list)
    return this
