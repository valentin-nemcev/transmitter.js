'use strict'


NodeBindingLine = require './node_binding_line'
BindingNodeLine = require './binding_node_line'
CompositeSource = require './composite_source'
Binding = require './binding'


module.exports = class BindingBuilder


  returnArg = (arg) -> arg


  constructor: ->
    @sources = []


  inDirection: (@direction) ->
    return this


  fromSource: (source) ->
    @sources.push source
    return this


  toTarget: (@target) ->
    return this


  withTransform: (@transform) ->
    return this


  buildSource: ->
    if @sources.length == 1
      @createSimpleSource(@sources[0])
    else
      @createCompositeSource(@sources)


  createSimpleSource: (source) ->
    new NodeBindingLine(source.getNodeSource(), @direction)


  createCompositeSource: (sources) ->
    parts = for source in sources
      line = new NodeBindingLine(source.getNodeSource(), @direction)
      [source, line]
    new CompositeSource(new Map(parts))


  _buildTarget: ->
    return new BindingNodeLine(@target.getNodeTarget(), @direction)


  bind: ->
    binding = new Binding(@transform ? returnArg)
    binding.bindSourceTarget(@buildSource(), @_buildTarget())
