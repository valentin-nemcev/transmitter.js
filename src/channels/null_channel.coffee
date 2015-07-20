'use strict'

class NullChannel

  connect: -> this
  disconnect: -> this


nullChannel = null

module.exports = -> nullChannel ?= new NullChannel
