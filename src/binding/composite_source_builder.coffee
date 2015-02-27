'use strict'


CompositeSource = require './composite_source'
CompositeSourcePart = require './composite_source_part'


module.exports = class CompositeSourceBuilder

  @build = =>
    new this()


  constructor: ->
    @parts = []


  withPart: (partSource) ->
    @_addSourcePart(partSource, initiatesMerge: yes)


  withPassivePart: (partSource) ->
    @_addSourcePart(partSource, initiatesMerge: no)


  _addSourcePart: (partSource, params) ->
    source = partSource.getMessageSender()
    @parts.push(new CompositeSourcePart(source,params))
    return this


  withMerge: (@merge) ->
    return this


  create: ->
    new CompositeSource(@parts, {@merge})


  getMessageSender: -> @create()
