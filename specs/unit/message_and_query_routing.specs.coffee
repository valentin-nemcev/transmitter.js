'use strict'

NodeSource = require 'transmitter/connection/node_source'
NodeTarget = require 'transmitter/connection/node_target'
NodeConnectionLine = require 'transmitter/connection/node_connection_line'
ConnectionNodeLine = require 'transmitter/connection/connection_node_line'
Transmission = require 'transmitter/transmission/transmission'
Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'


class StubPayload
  deliver: ->

class NodeStub
  NodeSource.extend(this)
  NodeTarget.extend(this)
  getResponseMessage: (sender) -> sender.createMessage(new StubPayload())
  getRelayedMessage:  (sender) -> sender.createMessage(new StubPayload())

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

    @message.sendToTargetNode(@node)

    expect(@target.receiveMessage).to.have.been.calledOnce


  specify 'query should be routed from node source to node target', ->
    @node = new NodeStub()
    @source = new SourceStub()
    new ConnectionNodeLine(@node.getNodeTarget())
      .setSource(@source).connect()
    sinon.spy(@source, 'receiveQuery')
    @query = new Query(@transmission)

    @query.sendToSourceNode(@node)

    expect(@source.receiveQuery).to.have.been.calledOnce


  specify 'query should be queued for response \
      when node targe has no sources with same direction', ->
    @node = new NodeStub()
    @source = new SourceStub()
    @target = new TargetStub()
    new NodeConnectionLine(@node.getNodeSource())
      .setTarget(@target).connect()
    new ConnectionNodeLine(@node.getNodeTarget(), @otherDirection)
      .setSource(@source).connect()
    sinon.spy(@target, 'receiveMessage')
    @query = new Query(@transmission, @queryDirection)

    @query.sendToSourceNode(@node)
    @transmission.respondToQueries()

    expect(@target.receiveMessage).to.have.been.calledOnce
