'use strict'


Variable = require './variable'


module.exports = class Record

  @defineLazy = (name, getValue) ->
    Object.defineProperty @prototype, name, 
      enumerable: yes, configurable: yes
      get: ->
        value = getValue.call(this)
        Object.defineProperty this, name,
          enumerable: yes, writable: no, value: value
        return @[name]


  @defineVar = (name) ->
    @defineLazy name, -> new Variable()
