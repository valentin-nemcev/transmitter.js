'use strict'


Binding = require './binding'
NodeBindingLine = require './node_binding_line'
BindingNodeLine = require './binding_node_line'


module.exports = class BindingBuilder


  returnArg = (arg) -> arg


  constructor: ->
    @transform ?= returnArg


  fromSource: (@source) ->
    return this


  toTarget: (@target) ->
    return this


  withTransform: (@transform) ->
    return this


  _buildSource: ->
    if @source.create?
      return @source.create()
    else
      return new NodeBindingLine(@source.getNodeSource())


  _buildTarget: ->
    return new BindingNodeLine(@target.getNodeTarget())


  bind: ->
    binding = new Binding(@transform)
    binding.bindSourceTarget(@_buildSource(), @_buildTarget())
