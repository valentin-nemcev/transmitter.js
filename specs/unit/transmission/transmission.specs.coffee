'use strict'


Transmission = require 'binder/transmission/transmission'
NodeSource = require 'binder/binding/node_source'


class NodeStub
  NodeSource.extend(this)


describe 'Transmission', ->

  beforeEach ->
    @transmission = new Transmission()
    @node = new NodeStub


  it 'responds to queries', ->
    @nodeSource = @node.getNodeSource()
    sinon.spy(@nodeSource, 'sendMessage')
    @createResponsePayload = sinon.stub()
    @createResponsePayload
      .withArgs(sinon.match.same(@node))
      .returns(@responsePayload = new class PayloadStub)

    @query = @transmission.createQuery(@createResponsePayload)

    @transmission.addQueryTo(@query, @node)
    @transmission.respondToQueries()

    @responseMessage = @nodeSource.sendMessage.args[0][0]
    expect(@responseMessage.getPayload()).to.equal(@responsePayload)
