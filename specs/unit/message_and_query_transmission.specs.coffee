'use strict'

NodeSource = require 'transmitter/connection/node_source'
NodeTarget = require 'transmitter/connection/node_target'
ConnectionBuilder = require 'transmitter/connection/builder'

Transmission = require 'transmitter/transmission/transmission'


class StubPayload
  deliver: ->

class NodeSourceStub
  NodeSource.extend(this)
  createResponsePayload: -> new StubPayload()

class NodeTargetStub
  NodeTarget.extend(this)


describe 'Message and query transmission', ->

  beforeEach ->
    @source = new NodeSourceStub()
    @target = new NodeTargetStub()

    new ConnectionBuilder()
      .fromSource @source
      .toTarget @target
      .connect()

    @transmission = new Transmission()


  it 'transmits message from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    @message = @transmission.createMessage(@payload)

    @message.sendFromSourceNode(@source)

    expect(@payload.deliver).to.have.been.calledWithSame(@target)


  it 'transmits query from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    sinon.stub(@source, 'createResponsePayload').returns(@payload)
    @query = @transmission.createQuery()

    @query.sendFromTargetNode(@target)
    @transmission.respondToQueries()

    expect(@payload.deliver).to.have.been.calledWithSame(@target)
