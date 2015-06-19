'use strict'

class NullChannel

  receiveConnectionMessage: -> this


nullChannel = null

module.exports = -> nullChannel ?= new NullChannel
