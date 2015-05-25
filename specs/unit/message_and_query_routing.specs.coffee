'use strict'

RelayNode = require 'transmitter/nodes/relay_node'
NodeConnectionLine = require 'transmitter/connection/node_connection_line'
ConnectionNodeLine = require 'transmitter/connection/connection_node_line'
Transmission = require 'transmitter/transmission/transmission'
Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'


class StubPayload
  deliver: ->

class NodeStub extends RelayNode
  createResponsePayload: ->
    new StubPayload()

  createRelayPayload: ->
    new StubPayload()

  acceptPayload: (payload) ->
    payload.deliver(this)
    return this


class TargetStub
  receiveMessage: ->

class SourceStub
  receiveQuery: ->

class DirectionStub
  inspect: -> '.'


describe 'Message and query routing', ->

  beforeEach ->
    @transmission = new Transmission()
    @otherDirection = new DirectionStub()
    @queryDirection = new DirectionStub()


  specify 'message should be routed from node target to node source', ->
    @node = new NodeStub()
    @target = new TargetStub()
    new NodeConnectionLine(@node.getNodeSource())
      .setTarget(@target).connect()
    sinon.spy(@target, 'receiveMessage')
    @message = new Message(@transmission, new StubPayload())

    @message.sendToNodeTarget(@node.getNodeTarget())

    expect(@target.receiveMessage).to.have.been.calledOnce


  specify 'query should be routed from node source to node target', ->
    @node = new NodeStub()
    @source = new SourceStub()
    new ConnectionNodeLine(@node.getNodeTarget())
      .setSource(@source).connect()
    sinon.spy(@source, 'receiveQuery')
    @query = new Query(@transmission)

    @query.sendToNodeTarget(@node.getNodeTarget())

    expect(@source.receiveQuery).to.have.been.calledOnce


  specify 'query should be queued for response \
      when node target has no sources with same direction', ->
    @node = new NodeStub()
    @source = new SourceStub()
    @target = new TargetStub()
    new NodeConnectionLine(@node.getNodeSource())
      .setTarget(@target).connect()
    new ConnectionNodeLine(@node.getNodeTarget(), @otherDirection)
      .setSource(@source).connect()
    sinon.spy(@target, 'receiveMessage')
    @query = new Query(@transmission, @queryDirection)

    @query.sendToNodeTarget(@node.getNodeTarget())
    @transmission.respondToQueries()

    expect(@target.receiveMessage).to.have.been.calledOnce
