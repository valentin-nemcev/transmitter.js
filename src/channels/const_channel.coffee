'use strict'


SimplexChannel = require './simplex_channel'
{forward, backward} = require '../directions'


module.exports = class ConstChannel extends SimplexChannel

  inForwardDirection: -> @inDirection(forward)
  inBackwardDirection: -> @inDirection(backward)

  withValue: -> return this
