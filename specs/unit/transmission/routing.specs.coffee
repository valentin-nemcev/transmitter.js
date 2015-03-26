'use strict'

NodeSource = require 'binder/binding/node_source'
NodeTarget = require 'binder/binding/node_target'
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


describe 'Message routing', ->

  beforeEach ->
    @transmission = new Transmission()


  specify 'message should be routed from node target to node source', ->
    @node = new NodeStub()
    @target = new TargetStub()
    @node.getNodeSource().bindTarget(@target)
    sinon.spy(@target, 'receiveMessage')
    @message = @transmission.createMessage(new StubPayload())

    @message.sendToTargetNode(@node)

    expect(@target.receiveMessage).to.have.been.calledOnce


  specify 'query should be routed from node source to node target', ->
    @node = new NodeStub()
    @source = new SourceStub()
    @node.getNodeTarget().bindSource(@source)
    sinon.spy(@source, 'receiveQuery')
    @query = @transmission.createQuery(->)

    @query.sendToSourceNode(@node)

    expect(@source.receiveQuery).to.have.been.calledOnce


  specify 'query should be queued for response when node has no targes', ->
    @node = new NodeStub()
    @target = new TargetStub()
    @node.getNodeSource().bindTarget(@target)
    sinon.spy(@target, 'receiveMessage')
    @query = @transmission.createQuery( -> new StubPayload())

    @query.sendToSourceNode(@node)
    @transmission.respondToQueries()

    expect(@target.receiveMessage).to.have.been.calledOnce
