'use strict'

NodeSource = require 'binder/binding/node_source'
NodeTarget = require 'binder/binding/node_target'
Transmission = require 'binder/transmission/transmission'


class StubPayload
  deliver: ->

class NodeStub
  NodeSource.extend(this)
  NodeTarget.extend(this)
  createResponsePayload: -> new StubPayload()

class SourceNodeStub
  NodeSource.extend(this)
  createResponsePayload: ->

class TargetNodeStub
  NodeTarget.extend(this)

class TargetStub
  receiveMessage: ->

class SourceStub
  receiveQuery: ->



describe 'Transmission cycles', ->

  beforeEach ->
    @transmission = new Transmission()


  describe 'with target node', ->

    beforeEach ->
      @targetNode = new TargetNodeStub()
      @source = new SourceStub()
      @targetNode.getNodeTarget().bindSource(@source)
      sinon.spy(@source, 'receiveQuery')

      @payload1 = new StubPayload()
      @payload2 = new StubPayload()
      sinon.spy(@payload2, 'deliver')


    specify 'second message should not be delivered', ->
      @message1 = @transmission.createMessage(@payload1)
      @message2 = @transmission.createMessage(@payload2)

      @message1.sendToTargetNode(@targetNode)
      @message2.sendToTargetNode(@targetNode)

      expect(@payload2.deliver).to.not.have.been.called


    specify 'query after message should not be sent', ->
      @message1 = @transmission.createMessage(@payload1)
      @query2 = @transmission.createQuery()

      @message1.sendToTargetNode(@targetNode)
      @query2.sendFromTargetNode(@targetNode)
      @transmission.respondToQueries()

      expect(@source.receiveQuery).to.not.have.been.called


    specify 'message after query should be sent', ->
      @query1 = @transmission.createQuery()
      @message2 = @transmission.createMessage(@payload2)

      @query1.sendFromTargetNode(@targetNode)
      @message2.sendToTargetNode(@targetNode)

      expect(@payload2.deliver).to.have.been.called


    specify 'second query should be sent', ->
      @query1 = @transmission.createQuery()
      @query2 = @transmission.createQuery()

      @query1.sendFromTargetNode(@targetNode)
      @query2.sendFromTargetNode(@targetNode)
      @transmission.respondToQueries()

      expect(@source.receiveQuery).to.have.been.calledTwice


  describe 'with source node', ->

    beforeEach ->
      @sourceNode = new SourceNodeStub()
      @target = new TargetStub()
      @sourceNode.getNodeSource().bindTarget(@target)
      sinon.spy(@target, 'receiveMessage')
      sinon.stub(@sourceNode, 'createResponsePayload', -> new StubPayload())


    specify 'second message should not be sent', ->
      @message1 = @transmission.createMessage(new StubPayload())
      @message2 = @transmission.createMessage(new StubPayload())

      @message1.sendFromSourceNode(@sourceNode)
      @message2.sendFromSourceNode(@sourceNode)

      expect(@target.receiveMessage).to.have.been.calledOnce
      expect(@target.receiveMessage).to.have.been.calledWithSame(@message1)


    specify 'query after message should not be delivered', ->
      @message1 = @transmission.createMessage(new StubPayload())
      @query2 = @transmission.createQuery()

      @message1.sendFromSourceNode(@sourceNode)
      @query2.sendToSourceNode(@sourceNode)
      @transmission.respondToQueries()

      expect(@sourceNode.createResponsePayload).to.not.have.been.called


    specify 'second query should be delivered', ->
      @query1 = @transmission.createQuery()
      @query2 = @transmission.createQuery()

      @query1.sendToSourceNode(@sourceNode)
      @query2.sendToSourceNode(@sourceNode)
      @transmission.respondToQueries()

      expect(@sourceNode.createResponsePayload).to.have.been.calledTwice
