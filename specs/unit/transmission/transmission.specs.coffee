'use strict'


Transmission = require 'binder/transmission/transmission'
NodeSource = require 'binder/binding/node_source'
NodeTarget = require 'binder/binding/node_target'


class NodeStub
  NodeSource.extend(this)
  NodeTarget.extend(this)

class StubPayload
  deliver: ->

class TargetStub
  receiveMessage: ->


describe 'Transmission', ->

  beforeEach ->
    @transmission = new Transmission()
    @node = new NodeStub

    @createResponsePayload = sinon.stub()
    @createResponsePayload
      .withArgs(sinon.match.same(@node))
      .returns(@responsePayload = new StubPayload())

    @target = new TargetStub()
    @node.getNodeSource().bindTarget(@target)
    sinon.spy(@target, 'receiveMessage')


  it 'responds to queries from nodes', ->
    @query = @transmission.createQuery(@createResponsePayload)

    @transmission.enqueueQueryFromNode(@query, @node)
    @transmission.respondToQueries()

    @responseMessage = @target.receiveMessage.args[0][0]
    expect(@responseMessage.getPayload()).to.equal(@responsePayload)


  it 'responds to queries with higher priority first', ->
    @node1 = new NodeStub()
    @node2 = new NodeStub()
    @target1 = new TargetStub()
    @target2 = new TargetStub()
    @node1.getNodeSource().bindTarget(@target1)
    @node2.getNodeSource().bindTarget(@target2)
    @query1 = @transmission.createQuery( -> new StubPayload())
    @query2 = @transmission.createQuery( -> new StubPayload())
    callOrder = []
    sinon.stub(@target1, 'receiveMessage', -> callOrder.push 1)
    sinon.stub(@target2, 'receiveMessage', -> callOrder.push 2)

    @transmission.enqueueQueryFromNode(@query1, @node1, 2)
    @transmission.enqueueQueryFromNode(@query2, @node2, 1)
    @transmission.respondToQueries()

    expect(callOrder).to.deep.equal([1, 2])


  it 'does not respond to query when message was already sent before', ->
    @message = @transmission.createMessage(new StubPayload())
    @message.sendFromSourceNode(@node)
    @query = @transmission.createQuery(@createResponsePayload)

    @transmission.enqueueQueryFromNode(@query, @node)
    @transmission.respondToQueries()

    expect(@target.receiveMessage).to.have.been.calledOnce
    expect(@target.receiveMessage).to.have.been.calledWithSame(@message)
