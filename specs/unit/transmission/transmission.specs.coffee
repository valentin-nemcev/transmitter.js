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

    @transmission.enqueueQueryForResponseFromNode(@query, @node)
    @transmission.respondToQueries()

    @responseMessage = @target.receiveMessage.args[0][0]
    expect(@responseMessage.getPayload()).to.equal(@responsePayload)


  it 'responds to queries to nodes', ->
    @query = @transmission.createQuery(@createResponsePayload)
    sinon.spy(@responsePayload, 'deliver')

    @transmission.enqueueQueryForResponseToNode(@query, @node)
    @transmission.respondToQueries()

    expect(@responsePayload.deliver).to.have.been.calledWithSame(@node)


  it 'does not respond to query when message was already sent before', ->
    @message = @transmission.createMessage(new StubPayload())
    @message.sendFromSourceNode(@node)
    @query = @transmission.createQuery(@createResponsePayload)

    @transmission.enqueueQueryForResponseFromNode(@query, @node)
    @transmission.respondToQueries()

    expect(@target.receiveMessage).to.have.been.calledOnce
    expect(@target.receiveMessage).to.have.been.calledWithSame(@message)
