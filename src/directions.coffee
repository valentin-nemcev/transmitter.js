'use strict'


module.exports = Object.freeze(
  forward:  Object.freeze {isForward: yes,  inspect: -> '→'}
  backward: Object.freeze {isBackward: yes, inspect: -> '←'}
  null:     Object.freeze {isNull: yes,     inspect: -> '-'}
)
