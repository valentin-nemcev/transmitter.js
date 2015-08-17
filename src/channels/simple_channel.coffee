'use strict'


assert = require 'assert'
Map = require 'collections/map'

directions = require '../directions'

NodeConnectionLine = require '../connection/node_connection_line'
ConnectionNodeLine = require '../connection/connection_node_line'
MergingConnectionTarget = require '../connection/merging_connection_target'
SeparatingConnectionSource =
  require '../connection/separating_connection_source'
Connection = require '../connection/connection'


module.exports = class SimpleChannel


  returnArg = (arg) -> arg


  inspect: -> '[' + @constructor.name + ']'


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


  fromSources: (sources) ->
    @sources.push sources...
    @forceMerging = yes
    return this


  toTarget: (target) ->
    @targets.push target if target?
    return this


  toTargets: (targets) ->
    @targets.push targets...
    @forceSeparating = yes
    return this


  toConnectionTarget: (@connectionTarget) ->
    return this


  withTransform: (@transform) ->
    return this


  getSource: ->
    @source ?= if @forceMerging or @sources.length > 1
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
    @target ?= if @connectionTarget?
      @connectionTarget
    else if @forceSeparating or @targets.length > 1
      @createSeparatingTarget(@targets)
    else
      @createSingleTarget(@targets[0])


  createSingleTarget: (target) ->
    new ConnectionNodeLine(target?.getNodeTarget(), @getDirection())


  createSeparatingTarget: (targets) ->
    parts = for target in targets
      line = new ConnectionNodeLine(target.getNodeTarget(), @getDirection())
      [target, line]
    new SeparatingConnectionSource(new Map(parts))


  getTransform: -> @transform ? returnArg


  getConnection: ->
    @connection ?= new Connection(@getSource(), @getTarget(), @getTransform())


  connect: (message) ->
    @getConnection().connect(message)
    return this


  disconnect: (message) ->
    @getConnection().disconnect(message)
    return this


  init: (tr) ->
    message = tr.createInitialConnectionMessage()
    @connect(message)
    message.updateTargetPoints()
    return this
