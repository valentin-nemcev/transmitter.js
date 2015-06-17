'use strict'


forward  = {
  isForward: yes
  inspect: -> '→'
  reverse: -> backward
  matches: (other) -> other.isOmni || other.isForward
}
backward = {
  isBackward: yes
  inspect: -> '←'
  reverse: -> forward
  matches: (other) -> other.isOmni || other.isBackward
}
nullDir = {
  isNull: yes
  inspect: -> '-'
  reverse: -> nullDir
  matches: (other) -> other.isOmni || other.isNull
}
omni = {
  isOmni: yes
  inspect: -> '↔'
  reverse: -> omni
  matches: (other) -> yes
}

directions = {forward, backward, null: nullDir, omni}
Object.freeze(dir) for name, dir of directions

module.exports = Object.freeze(directions)
