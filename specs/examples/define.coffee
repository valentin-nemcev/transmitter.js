'use strict'


before ->
  @define = (name, value) ->
    value.inspect = (-> name)
    @[name] = value
    return value
