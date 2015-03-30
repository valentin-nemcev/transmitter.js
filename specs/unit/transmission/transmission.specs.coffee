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


  it 'responds to queries to nodes', ->
    @query = @transmission.createQuery(@createResponsePayload)
    sinon.spy(@responsePayload, 'deliver')

    @transmission.enqueueQueryToNode(@query, @node)
    @transmission.respondToQueries()

    expect(@responsePayload.deliver).to.have.been.calledWithSame(@node)


  it 'responds to queries with higher priority first', ->
    @node1 = new NodeStub()
    @node2 = new NodeStub()
    @responsePayload1 = new StubPayload()
    @responsePayload2 = new StubPayload()
    @query1 = @transmission.createQuery( => @responsePayload1)
    @query2 = @transmission.createQuery( => @responsePayload2)
    callOrder = []
    sinon.stub(@responsePayload1, 'deliver', -> callOrder.push 1)
    sinon.stub(@responsePayload2, 'deliver', -> callOrder.push 2)

    @transmission.enqueueQueryToNode(@query1, @node1, 2)
    @transmission.enqueueQueryToNode(@query2, @node2, 1)
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
