'use strict'

NodeSource = require 'binder/binding/node_source'
NodeTarget = require 'binder/binding/node_target'
NodeBindingLine = require 'binder/binding/node_binding_line'
BindingNodeLine = require 'binder/binding/binding_node_line'
Transmission = require 'binder/transmission/transmission'


class NodeStub
  NodeSource.extend(this)
  NodeTarget.extend(this)

class StubPayload
  deliver: ->

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
    new NodeBindingLine(@node.getNodeSource()).bindTarget(@target)
    sinon.spy(@target, 'receiveMessage')
    @message = @transmission.createMessage(new StubPayload())

    @message.sendToTargetNode(@node)

    expect(@target.receiveMessage).to.have.been.calledOnce


  specify 'query should be routed from node source to node target', ->
    @node = new NodeStub()
    @source = new SourceStub()
    new BindingNodeLine(@node.getNodeTarget()).bindSource(@source)
    sinon.spy(@source, 'receiveQuery')
    @query = @transmission.createQuery(->)

    @query.sendToSourceNode(@node)

    expect(@source.receiveQuery).to.have.been.calledOnce


  specify 'query should be queued for response \
      when node targe has no sources with same direction', ->
    @node = new NodeStub()
    @source = new SourceStub()
    @target = new TargetStub()
    new NodeBindingLine(@node.getNodeSource(), @otherDirection)
      .bindTarget(@target)
    new BindingNodeLine(@node.getNodeTarget())
      .bindSource(@source)
    sinon.spy(@target, 'receiveMessage')
    @query = @transmission.createQuery((-> new StubPayload()), @queryDirection)

    @query.sendToSourceNode(@node)
    @transmission.respondToQueries()

    expect(@target.receiveMessage).to.have.been.calledOnce
