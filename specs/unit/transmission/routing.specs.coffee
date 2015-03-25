'use strict'

NodeSource = require 'binder/binding/node_source'
NodeTarget = require 'binder/binding/node_target'
Transmission = require 'binder/transmission/transmission'


class NodeStub
  NodeSource.extend(this)
  NodeTarget.extend(this)

class SourceNodeStub
  NodeSource.extend(this)

class TargetNodeStub
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


  describe 'multiple message through same node', ->

    specify 'message should not be sent to target node more than once', ->
      @targetNode = new TargetNodeStub()
      @payload1 = new StubPayload()
      @payload2 = new StubPayload()
      sinon.spy(@payload2, 'deliver')
      @message1 = @transmission.createMessage(@payload1)
      @message2 = @transmission.createMessage(@payload2)

      @message1.sendToTargetNode(@targetNode)
      @message2.sendToTargetNode(@targetNode)

      expect(@payload2.deliver).to.not.have.been.called


    specify 'message should not be sent from source node more than once', ->
      @sourceNode = new SourceNodeStub()
      @target = new TargetStub()
      @sourceNode.getNodeSource().bindTarget(@target)
      sinon.spy(@target, 'receiveMessage')
      @message1 = @transmission.createMessage(new StubPayload())
      @message2 = @transmission.createMessage(new StubPayload())

      @message1.sendFromSourceNode(@sourceNode)
      @message2.sendFromSourceNode(@sourceNode)

      expect(@target.receiveMessage).to.have.been.calledOnce
      expect(@target.receiveMessage).to.have.been.calledWithSame(@message1)


    specify 'message should not be sent from node \
        that received another message', ->
      @node = new NodeStub()
      @target = new TargetStub()
      @node.getNodeSource().bindTarget(@target)
      sinon.spy(@target, 'receiveMessage')
      @message1 = @transmission.createMessage(new StubPayload())
      @message2 = @transmission.createMessage(new StubPayload())

      @message1.sendToTargetNode(@node)
      @message2.sendFromSourceNode(@node)

      expect(@target.receiveMessage).to.have.been.calledOnce
      expect(@target.receiveMessage)
        .to.not.have.been.calledWithSame(@message2)


    specify 'message should not be sent to node \
        that sent another message', ->
      @node = new NodeStub()
      @payload1 = new StubPayload()
      @payload2 = new StubPayload()
      sinon.spy(@payload2, 'deliver')
      @message1 = @transmission.createMessage(@payload1)
      @message2 = @transmission.createMessage(@payload2)

      @message1.sendFromSourceNode(@node)
      @message2.sendToTargetNode(@node)

      expect(@payload2.deliver).to.not.have.been.called
