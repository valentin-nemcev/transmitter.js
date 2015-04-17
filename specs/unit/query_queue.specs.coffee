'use strict'


Transmission = require 'transmitter/transmission/transmission'
NodeSource = require 'transmitter/connection/node_source'
NodeTarget = require 'transmitter/connection/node_target'


class StubPayload
  deliver: ->

class NodeStub
  NodeSource.extend(this)
  NodeTarget.extend(this)
  createResponsePayload: -> new StubPayload()

class TargetStub
  receiveMessage: ->
  isConst: -> yes


describe 'Query queue', ->

  beforeEach ->
    @transmission = new Transmission()


  it 'responds to queries from nodes', ->
    @node = new NodeStub()
    @target = new TargetStub()
    @node.getNodeSource().connectTarget(@target)
    sinon.spy(@node, 'createResponsePayload')
    sinon.spy(@target, 'receiveMessage')
    @query = @transmission.createQuery()

    @transmission.enqueueQueryFromNode(@query, @node)
    @transmission.respondToQueries()

    @responseMessage = @target.receiveMessage.firstCall.args[0]
    expect(@responseMessage.getPayload())
      .to.equal(@node.createResponsePayload.firstCall.returnValue)


  it 'responds to queries with higher priority first', ->
    @node1 = new NodeStub()
    @node2 = new NodeStub()
    @target1 = new TargetStub()
    @target2 = new TargetStub()
    @node1.getNodeSource().connectTarget(@target1)
    @node2.getNodeSource().connectTarget(@target2)
    @query1 = @transmission.createQuery()
    @query2 = @transmission.createQuery()
    callOrder = []
    sinon.stub(@target1, 'receiveMessage', -> callOrder.push 1)
    sinon.stub(@target2, 'receiveMessage', -> callOrder.push 2)

    @transmission.enqueueQueryFromNode(@query1, @node1, 2)
    @transmission.enqueueQueryFromNode(@query2, @node2, 1)
    @transmission.respondToQueries()

    expect(callOrder).to.deep.equal([1, 2])


  it 'does not respond to query when message was already sent before', ->
    @node = new NodeStub()
    @target = new TargetStub()
    @node.getNodeSource().connectTarget(@target)
    sinon.spy(@target, 'receiveMessage')
    @message = @transmission.createMessage(new StubPayload())
    @message.sendFromSourceNode(@node)
    @query = @transmission.createQuery()

    @transmission.enqueueQueryFromNode(@query, @node)
    @transmission.respondToQueries()

    expect(@target.receiveMessage).to.have.been.calledOnce
    expect(@target.receiveMessage).to.have.been.calledWithSame(@message)


  it 'responds to queries created as a result of previous response', ->
    @node1 = new NodeStub()
    @node2 = new NodeStub()
    @target1 = new TargetStub()
    @target2 = new TargetStub()
    @node1.getNodeSource().connectTarget(@target1)
    @node2.getNodeSource().connectTarget(@target2)
    @query1 = @transmission.createQuery()
    @query2 = @transmission.createQuery()
    sinon.stub(@target1, 'receiveMessage', =>
      @transmission.enqueueQueryFromNode(@query2, @node2)
    )
    sinon.spy(@target2, 'receiveMessage')

    @transmission.enqueueQueryFromNode(@query1, @node1)
    @transmission.respondToQueries()

    expect(@target2.receiveMessage).to.have.been.calledOnce
