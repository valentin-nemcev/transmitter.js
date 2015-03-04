'use strict'


class exports.EventPayload

  toValue: (value) -> new exports.ValuePayload(value)



class exports.ValuePayload

  constructor: (@value) ->


  deliver: (target) ->
    target.receiveValue(@value)
    return this



class exports.StatePayload

  @updateNodeAndCreate = (node, value) ->
    node.setValue(value)
    return new this(node)


  constructor: (@node) ->


  deliver: (targetNode) ->
    targetNode.setValue(@node.getValue())
    return this

