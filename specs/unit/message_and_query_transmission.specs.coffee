'use strict'

NodeSource = require 'transmitter/connection/node_source'
NodeTarget = require 'transmitter/connection/node_target'
ConnectionBuilder = require 'transmitter/connection/builder'

Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'
Transmission = require 'transmitter/transmission/transmission'

Transmitter = require 'transmitter'


class StubPayload
  deliver: ->

class NodeSourceStub
  NodeSource.extend(this)
  getResponseMessage: (sender) -> sender.createMessage(new StubPayload())

class NodeTargetStub
  NodeTarget.extend(this)


describe 'Message and query transmission', ->

  beforeEach ->
    @source = new NodeSourceStub()
    @target = new NodeTargetStub()

    new ConnectionBuilder(Transmitter)
      .fromSource @source
      .toTarget @target
      .connect()

    @transmission = new Transmission()


  it 'transmits message from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    @message = new Message(@transmission, @payload)

    @message.sendFromSourceNode(@source)

    expect(@payload.deliver).to.have.been.calledWithSame(@target)


  it 'transmits query from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    sinon.stub(@source, 'getResponseMessage', (sender) =>
      sender.createMessage(@payload)
    )
    @query = new Query(@transmission)

    @query.sendFromTargetNode(@target)
    @transmission.respondToQueries()

    expect(@payload.deliver).to.have.been.calledWithSame(@target)
