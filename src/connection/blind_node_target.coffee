'use strict'


module.exports = class BlindNodeTarget

  inspect: -> '|>' + @node.inspect()

  constructor: (@node) ->

  getChannelNodesFor: (comm) -> []

  receiveQuery: (query) ->
    return this
