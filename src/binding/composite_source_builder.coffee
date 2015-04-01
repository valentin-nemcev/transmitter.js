'use strict'


CompositeSource = require './composite_source'
NodeBindingLine = require './node_binding_line'

{StatePayload} = require '../transmission/payloads'

module.exports = class CompositeSourceBuilder

  constructor: ->
    @parts = new Map()


  withPart: (node) ->
    @_addSourcePart(node, {queryForMerge: yes})


  withPassivePart: (node) ->
    @_addSourcePart(node, {})


  _addSourcePart: (node, opts) ->
    @parts.set(node, new NodeBindingLine(node.getNodeSource(), null, opts))
    return this


  build: ->
    new CompositeSource(@parts, {})
