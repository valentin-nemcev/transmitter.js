'use strict'


CompositeSource = require './composite_source'
CompositeSourcePart = require './composite_source_part'


module.exports = class CompositeSourceBuilder

  @build = =>
    new this()


  constructor: ->
    @parts = []


  withPart: (node) ->
    @_addSourcePart(node, initiatesMerge: yes)


  withPassivePart: (node) ->
    @_addSourcePart(node, initiatesMerge: no)


  _addSourcePart: (node, params) ->
    @parts.push(new CompositeSourcePart(node, node.getNodeSource(), params))
    return this


  create: ->
    new CompositeSource(@parts, {})


  getNodeSource: -> @create()
