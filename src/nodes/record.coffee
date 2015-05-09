'use strict'


Variable = require './variable'


module.exports = class Record

  @defineLazy = (name, get) ->
    Object.defineProperty @prototype, name, 
      enumerable: yes, configurable: yes
      get: ->
        value = get.call(this)
        value.inspect ?= => this.inspect() + '.' + name
        Object.defineProperty this, name,
          enumerable: yes, writable: no, value: value
        return @[name]


  @defineVar = (name) ->
    @defineLazy name, -> new Variable()
