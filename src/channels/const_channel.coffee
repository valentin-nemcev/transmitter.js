'use strict'


SimpleChannel = require './simple_channel'


module.exports = class ConstChannel extends SimpleChannel

  withValue: -> return this
