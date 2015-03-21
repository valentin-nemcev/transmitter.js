'use strict'


CompositeSource = require './composite_source'
CompositeSourcePart = require './composite_source_part'

{StatePayload} = require '../transmission/payloads'

module.exports = class CompositeSourceBuilder

  @build = =>
    new this()


  constructor: ->
    @parts = []


  withPart: (node, opts = {}) ->
    {queryForMergeWith} = opts
    queryForMergeWith ?= StatePayload.create
    @_addSourcePart(node, {queryForMergeWith})


  withPassivePart: (node) ->
    @_addSourcePart(node, {})


  _addSourcePart: (node, opts) ->
    @parts.push(new CompositeSourcePart(node, node.getNodeSource(), opts))
    return this


  create: ->
    new CompositeSource(@parts, {})


  getNodeSource: -> @create()
