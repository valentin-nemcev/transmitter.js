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
