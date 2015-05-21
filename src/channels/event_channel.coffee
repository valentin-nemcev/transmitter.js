'use strict'


SimpleChannel = require './simple_channel'
{forward, backward} = require '../directions'


module.exports = class EventChannel extends SimpleChannel

  inForwardDirection: -> @inDirection(forward)
  inBackwardDirection: -> @inDirection(backward)
