'use strict'


CompositeSource = require './composite_source'
CompositeSourcePart = require './composite_source_part'


module.exports = class CompositeSourceBuilder

  @build = =>
    new this()


  constructor: ->
    @parts = []


  withPart: (partSource) ->
    @parts.push new CompositeSourcePart(partSource, initiatesMerge: yes)
    return this


  withPassivePart: (partSource) ->
    @parts.push new CompositeSourcePart(partSource, initiatesMerge: no)
    return this


  withMerge: (@merge) ->
    return this


  create: ->
    new CompositeSource(@parts, {@merge})
