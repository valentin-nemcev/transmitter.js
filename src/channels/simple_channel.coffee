'use strict'


{inspect} = require 'util'
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


  assertPresent: (name, value) ->
    if not value or (value?.length? and value.length is 0)
      throw new Error name + " must be present, #{inspect value} given"
    return this


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
    @assertPresent('Source', source)
    @sources.push source if source?
    return this


  fromSources: (sources) ->
    @assertPresent('Sources', sources)
    @sources.push sources...
    @forceMerging = yes
    return this


  requireMatchingSourcePriorities: ->
    @sourcePrioritiesShouldMatch = yes
    return this


  toTarget: (target) ->
    @assertPresent('Target', target)
    @targets.push target if target?
    return this


  toTargets: (targets) ->
    @assertPresent('Target', targets)
    @targets.push targets...
    @forceSeparating = yes
    return this


  toConnectionTarget: (@connectionTarget) ->
    @assertPresent('Connection target', @connectionTarget)
    return this


  withTransform: (@transform) ->
    return this


  getSource: ->
    @source ?= if @forceMerging or @sources.length > 1
      @createMergingSource(@sources,
        prioritiesShouldMatch: @sourcePrioritiesShouldMatch)
    else @createSingleSource(@sources[0])


  createSingleSource: (source) ->
    new NodeConnectionLine(source?.getNodeSource(), @getDirection())


  createMergingSource: (sources, opts) ->
    parts = for source in sources
      line = new NodeConnectionLine(source.getNodeSource(), @getDirection())
      [source, line]
    new MergingConnectionTarget(new Map(parts), opts)


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
    message.sendToTargetPoints()
    return this
