'use strict'


assert = require 'assert'
Map = require 'collections/map'

directions = require '../directions'

NodeConnectionLine = require '../connection/node_connection_line'
ConnectionNodeLine = require '../connection/connection_node_line'
MergingConnectionTarget = require '../connection/merging_connection_target'
Connection = require '../connection/connection'

ConnectionPayload = require '../payloads/connection'


module.exports = class SimpleChannel


  returnArg = (arg) -> arg


  constructor: ->
    @sources = []
    @targets = []


  inForwardDirection: -> @inDirection(directions.forward)
  inBackwardDirection: -> @inDirection(directions.backward)

  inDirection: (@direction) ->
    return this

  getDirection: -> 
    if @connectionTarget?
      directions.omni
    else
      @direction ? directions.null


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
    new NodeConnectionLine(source?.getNodeSource(), @getDirection())


  createMergingSource: (sources) ->
    parts = for source in sources
      line = new NodeConnectionLine(source.getNodeSource(), @getDirection())
      [source, line]
    new MergingConnectionTarget(new Map(parts))


  getTarget: ->
    @target ?= @connectionTarget ? @createSingleTarget(@targets[0])


  createSingleTarget: (target) ->
    new ConnectionNodeLine(target?.getNodeTarget(), @getDirection())


  getTransform: -> @transform ? returnArg


  getConnection: ->
    @connection ?= new Connection(@getSource(), @getTarget(), @getTransform())


  connect: (message) ->
    @getConnection().connect(message)
    return this


  disconnect: (message) ->
    @getConnection().connect(message)
    return this
