'use strict'


Transmission = require 'transmitter/transmission/transmission'
Query = require 'transmitter/transmission/query'
Message = require 'transmitter/transmission/message'
RelayNode = require 'transmitter/nodes/relay_node'


class StubPayload
  deliver: ->

class NodeStub extends RelayNode
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
    @query = new Query(@transmission)

    @transmission.enqueueQueryFor(@query, @node)
    @transmission.respondToQueries()

    expect(@node.createResponsePayload).to.have.been.calledOnce


  it 'responds to queries with lower order first', ->
    @node1 = new NodeStub()
    @node2 = new NodeStub()
    @target1 = new TargetStub()
    @target2 = new TargetStub()
    @node1.getNodeSource().connectTarget(@target1)
    @node2.getNodeSource().connectTarget(@target2)
    @query1 = new Query(@transmission)
    @query2 = new Query(@transmission)
    callOrder = []
    sinon.stub(@target1, 'receiveMessage', -> callOrder.push 1)
    sinon.stub(@target2, 'receiveMessage', -> callOrder.push 2)

    @transmission.enqueueQueryFor(@query2, @node2, 2)
    @transmission.enqueueQueryFor(@query1, @node1, 1)
    @transmission.respondToQueries()

    expect(callOrder).to.deep.equal([1, 2])


  it 'does not respond to query when message was already sent before', ->
    @node = new NodeStub()
    @target = new TargetStub()
    @node.getNodeSource().connectTarget(@target)
    sinon.spy(@target, 'receiveMessage')
    @message = new Message(@transmission, new StubPayload())
    @message.sendToNodeSource(@node.getNodeSource())
    @query = new Query(@transmission)

    @transmission.enqueueQueryFor(@query, @node)
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
    @query1 = new Query(@transmission)
    @query2 = new Query(@transmission)
    sinon.stub(@target1, 'receiveMessage', =>
      @transmission.enqueueQueryFor(@query2, @node2)
    )
    sinon.spy(@target2, 'receiveMessage')

    @transmission.enqueueQueryFor(@query1, @node1)
    @transmission.respondToQueries()

    expect(@target2.receiveMessage).to.have.been.calledOnce
