'use strict'


{inspect} = require 'util'
Variable = require './variable'


module.exports = class Record

  inspect: -> '[' + @constructor.name + ']'


  @defineLazy = (name, get) ->
    Object.defineProperty @prototype, name, 
      enumerable: yes, configurable: yes
      get: ->
        value = get.call(this)
        value.inspect ?= => inspect(this) + '.' + name
        Object.defineProperty this, name,
          enumerable: yes, writable: no, value: value
        return @[name]


  @defineVar = (name) ->
    @defineLazy name, -> new Variable()
