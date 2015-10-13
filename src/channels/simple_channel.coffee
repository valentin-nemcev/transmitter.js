'use strict'


{inspect} = require 'util'
Map = require 'collections/map'

directions = require '../directions'

NodeConnectionLine = require '../connection/node_connection_line'
ConnectionNodeLine = require '../connection/connection_node_line'
MergingConnectionTarget = require '../connection/merging_connection_target'
SeparatingConnectionSource =
  require '../connection/separating_connection_source'
DuplicatingConnectionSource =
  require '../connection/duplicating_connection_source'
Connection = require '../connection/connection'


module.exports = class SimpleChannel


  returnArg = (arg) -> arg


  inspect: -> '[' + @constructor.name + ']'


  constructor: ->
    @sources = []
    @targets = []
    @connectionTargets = []


  inForwardDirection: -> @inDirection(directions.forward)
  inBackwardDirection: -> @inDirection(directions.backward)

  inDirection: (@direction) ->
    return this

  getDirection: ->
    if @connectionTargets.length
      directions.omni
    else
      @direction ? directions.null


  assertSource: (source) ->
    unless source?.getNodeSource?
      throw new Error "#{inspect source} is not a valid source node"
    return this


  fromSource: (source) ->
    @assertSource(source)
    @sources.push source
    return this


  fromSources: (sources...) ->
    for source in sources
      @assertSource(source)
      @sources.push source
    @forceMerging = yes
    return this


  fromDynamicSources: (sources) ->
    for source in sources
      @assertSource(source)
      @sources.push source
    @forceMerging = yes
    return this


  requireMatchingSourcePriorities: ->
    @sourcePrioritiesShouldMatch = yes
    return this



  assertTarget: (target) ->
    unless target?.getNodeTarget?
      throw new Error "#{inspect target} is not a valid target node"
    return this


  toTarget: (target) ->
    @assertTarget(target)
    @targets.push target
    return this


  toTargets: (targets...) ->
    for target in targets
      @assertTarget(target)
      @targets.push target
    @forceSeparating = yes
    return this


  toDynamicTargets: (targets) ->
    for target in targets
      @assertTarget(target)
      @targets.push target
    @forceSeparating = yes
    return this



  assertConnectionTarget: (connectionTarget) ->
    unless connectionTarget?.isConnectionTarget?()
      throw new Error "#{inspect connectionTarget} is not a valid target node"
    return this


  toConnectionTarget: (connectionTarget) ->
    @assertConnectionTarget(connectionTarget)
    @connectionTargets.push connectionTarget
    return this


  toConnectionTargets: (connectionTargets...) ->
    for connectionTarget in connectionTargets
      @assertConnectionTarget(connectionTarget)
      @connectionTargets.push connectionTarget
    return this


  withTransform: (@transform) ->
    return this


  getSource: ->
    @source ?= @createMergingSource(
      @sources,
      singleSource: not @forceMerging and @sources.length == 1,
      prioritiesShouldMatch: @sourcePrioritiesShouldMatch
    )


  createMergingSource: (sources, opts) ->
    parts = for source in sources
      line = new NodeConnectionLine(source.getNodeSource(), @getDirection())
      [source, line]
    new MergingConnectionTarget(new Map(parts), opts)


  getTarget: ->
    @target ?=
      if @connectionTargets.length
        @createDuplicatingTarget(@connectionTargets)
      else
        @createSeparatingTarget(
          @targets,
          singleTarget: not @forceSeparating and @targets.length == 1
        )


  createSeparatingTarget: (targets, opts) ->
    parts = for target in targets
      line = new ConnectionNodeLine(target.getNodeTarget(), @getDirection())
      [target, line]
    new SeparatingConnectionSource(new Map(parts), opts)


  createDuplicatingTarget: (targets) ->
    new DuplicatingConnectionSource(targets)


  getTransform: -> @transform ? returnArg


  nullConnection =
    connect: -> this
    disconnect: -> this

  getConnection: ->
    @connection ?=
      if not @getTarget()?
        nullConnection
      else
        new Connection(@getSource(), @getTarget(), @getTransform())


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
