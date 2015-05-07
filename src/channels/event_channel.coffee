'use strict'


SimplexChannel = require './simplex_channel'
{forward, backward} = require '../directions'


module.exports = class EventChannel extends SimplexChannel

  inForwardDirection: -> @inDirection(forward)
  inBackwardDirection: -> @inDirection(backward)
