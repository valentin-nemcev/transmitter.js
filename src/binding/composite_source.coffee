'use strict'


module.exports = class CompositeBindingSource

  constructor: (@sourceParts) ->


  attachOutgoingBinding: (binding) ->
    for name, part of @sourceParts
      part.attachOutgoingBinding(binding)
    return this
