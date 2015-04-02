'use strict'

NodeSource = require 'binder/connection/node_source'
NodeTarget = require 'binder/connection/node_target'
NodeConnectionLine = require 'binder/connection/node_connection_line'
ConnectionNodeLine = require 'binder/connection/connection_node_line'
Transmission = require 'binder/transmission/transmission'


class StubPayload
  deliver: ->

class NodeStub
  NodeSource.extend(this)
  NodeTarget.extend(this)
  createResponsePayload: -> new StubPayload()

class TargetStub
  receiveMessage: ->

class SourceStub
  receiveQuery: ->

class DirectionStub


describe 'Message and query routing', ->

  beforeEach ->
    @transmission = new Transmission()
    @otherDirection = new DirectionStub()
    @queryDirection = new DirectionStub()


  specify 'message should be routed from node target to node source', ->
    @node = new NodeStub()
    @target = new TargetStub()
    new NodeConnectionLine(@node.getNodeSource()).connectTarget(@target)
    sinon.spy(@target, 'receiveMessage')
    @message = @transmission.createMessage(new StubPayload())

    @message.sendToTargetNode(@node)

    expect(@target.receiveMessage).to.have.been.calledOnce


  specify 'query should be routed from node source to node target', ->
    @node = new NodeStub()
    @source = new SourceStub()
    new ConnectionNodeLine(@node.getNodeTarget()).connectSource(@source)
    sinon.spy(@source, 'receiveQuery')
    @query = @transmission.createQuery()

    @query.sendToSourceNode(@node)

    expect(@source.receiveQuery).to.have.been.calledOnce


  specify 'query should be queued for response \
      when node targe has no sources with same direction', ->
    @node = new NodeStub()
    @source = new SourceStub()
    @target = new TargetStub()
    new NodeConnectionLine(@node.getNodeSource())
      .connectTarget(@target)
    new ConnectionNodeLine(@node.getNodeTarget(), @otherDirection)
      .connectSource(@source)
    sinon.spy(@target, 'receiveMessage')
    @query = @transmission.createQuery(@queryDirection)

    @query.sendToSourceNode(@node)
    @transmission.respondToQueries()

    expect(@target.receiveMessage).to.have.been.calledOnce
