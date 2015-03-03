'use strict'


module.exports = class Query

  enquireTarget: (node) ->
    node.getMessageReceiver().enquire(this)
    return this
