'use strict'


Variable = require '../nodes/variable'
Transmission = require '../transmission/transmission'


module.exports = class LocationHash extends Variable

  constructor: ->
    window.addEventListener 'hashchange', =>
      Transmission.start (tr) =>
        @originate(tr)

  set: (value) -> window.location.hash = value; this

  get: -> window.location.hash
