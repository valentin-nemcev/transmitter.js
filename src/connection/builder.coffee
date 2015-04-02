'use strict'


NodeConnectionLine = require './node_connection_line'
ConnectionNodeLine = require './connection_node_line'
MergingConnectionTarget = require './merging_connection_target'
Connection = require './connection'


module.exports = class ConnectionBuilder


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
      @createSingleSource(@sources[0])
    else
      @createMergingSource(@sources)


  createSingleSource: (source) ->
    new NodeConnectionLine(source.getNodeSource(), @direction)


  createMergingSource: (sources) ->
    parts = for source in sources
      line = new NodeConnectionLine(source.getNodeSource(), @direction)
      [source, line]
    new MergingConnectionTarget(new Map(parts))


  _buildTarget: ->
    return new ConnectionNodeLine(@target.getNodeTarget(), @direction)


  connect: ->
    new Connection(@transform ? returnArg)
      .connectSourceTarget(@buildSource(), @_buildTarget())
