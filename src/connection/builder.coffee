'use strict'


assert = require 'assert'

NodeConnectionLine = require './node_connection_line'
ConnectionNodeLine = require './connection_node_line'
MergingConnectionTarget = require './merging_connection_target'
Connection = require './connection'


module.exports = class ConnectionBuilder


  returnArg = (arg) -> arg


  constructor: (@Transmitter) ->
    @sources = []
    @targets = []


  inDirection: (@direction) ->
    return this


  fromSource: (source) ->
    @sources.push source if source?
    return this


  toTarget: (target) ->
    @targets.push target if target?
    return this


  toConnectionTarget: (@connectionTarget) ->
    return this


  withTransform: (@transform) ->
    return this


  getSource: ->
    @source ?= if @sources.length > 1
      @createMergingSource(@sources)
    else @createSingleSource(@sources[0])


  createSingleSource: (source) ->
    new NodeConnectionLine(source?.getNodeSource(), @direction)


  createMergingSource: (sources) ->
    parts = for source in sources
      line = new NodeConnectionLine(source.getNodeSource(), @direction)
      [source, line]
    new MergingConnectionTarget(new Map(parts))


  getTarget: ->
    @target ?= @connectionTarget ? @createSingleTarget(@targets[0])


  createSingleTarget: (target) ->
    new ConnectionNodeLine(target?.getNodeTarget(), @direction)


  getTransform: -> @transform ? returnArg


  getConnection: ->
    @connection ?= new Connection(@getSource(), @getTarget(), @getTransform())


  connect: ->
    @Transmitter.connect(@getConnection())


  receiveConnectionMessage: (message) ->
    @getConnection().receiveConnectionMessage(message)
    return this
