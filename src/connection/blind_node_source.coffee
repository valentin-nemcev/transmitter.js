'use strict'


module.exports = class BlindNodeSource

  inspect: -> @node.inspect() + '<|'

  constructor: (@node) ->

  getChannelNodesFor: (comm) -> []
