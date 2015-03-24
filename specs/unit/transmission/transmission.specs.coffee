'use strict'


Transmission = require 'binder/transmission/transmission'
NodeSource = require 'binder/binding/node_source'


class NodeStub
  NodeSource.extend(this)

class PayloadStub

class TargetStub
  receiveMessage: ->


describe 'Transmission', ->

  beforeEach ->
    @transmission = new Transmission()
    @node = new NodeStub

    @createResponsePayload = sinon.stub()
    @createResponsePayload
      .withArgs(sinon.match.same(@node))
      .returns(@responsePayload = new PayloadStub())

    @target = new TargetStub()
    @node.getNodeSource().bindTarget(@target)
    sinon.spy(@target, 'receiveMessage')


  it 'responds to queries', ->
    @query = @transmission.createQuery(@createResponsePayload)

    @transmission.addQueryTo(@query, @node)
    @transmission.respondToQueries()

    @responseMessage = @target.receiveMessage.args[0][0]
    expect(@responseMessage.getPayload()).to.equal(@responsePayload)


  it 'does not respond to query when message was already sent before', ->
    @message = @transmission.createMessage(new PayloadStub())
    @message.sendFromSourceNode(@node)
    @query = @transmission.createQuery(@createResponsePayload)

    @transmission.addQueryTo(@query, @node)
    @transmission.respondToQueries()

    expect(@target.receiveMessage).to.have.been.calledOnce
    expect(@target.receiveMessage).to.have.been.calledWithSame(@message)
