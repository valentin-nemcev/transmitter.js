'use strict'


module.exports = class BlindNodeTarget

  getChannelNodesFor: (comm) -> []

  receiveQuery: (query) ->
    return this
