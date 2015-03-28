'use strict'


CompositeSource = require './composite_source'
NodeBindingLine = require './node_binding_line'

{StatePayload} = require '../transmission/payloads'

module.exports = class CompositeSourceBuilder

  @build = =>
    new this()


  constructor: ->
    @parts = new Map()


  withPart: (node, opts = {}) ->
    {queryForMergeWith} = opts
    queryForMergeWith ?= StatePayload.create
    @_addSourcePart(node, {queryForMergeWith})


  withPassivePart: (node) ->
    @_addSourcePart(node, {})


  _addSourcePart: (node, opts) ->
    @parts.set(node, new NodeBindingLine(node.getNodeSource(), null, opts))
    return this


  create: ->
    new CompositeSource(@parts, {})
