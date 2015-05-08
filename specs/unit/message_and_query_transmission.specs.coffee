'use strict'

EventSource = require 'transmitter/nodes/event_source'
EventTarget = require 'transmitter/nodes/event_target'
SimplexChannel = require 'transmitter/channels/simplex_channel'

Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'
Transmission = require 'transmitter/transmission/transmission'

Transmitter = require 'transmitter'


class StubPayload
  deliver: ->

class NodeSourceStub extends EventSource
  createResponsePayload: -> new StubPayload()

class NodeTargetStub extends EventTarget


describe 'Message and query transmission', ->

  beforeEach ->
    @source = new NodeSourceStub()
    @target = new NodeTargetStub()

    Transmitter.startTransmission (tr) =>
      new SimplexChannel()
        .fromSource @source
        .toTarget @target
        .connect(tr)

    @transmission = new Transmission()


  it 'transmits message from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    @message = new Message(@transmission, @payload)

    @message.sendToNodeSource(@source.getNodeSource())

    expect(@payload.deliver).to.have.been
      .calledWith(sinon.match.same(@target))


  it 'transmits query from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    sinon.stub(@source, 'createResponsePayload').returns(@payload)
    @query = new Query(@transmission)

    @query.sendToNodeTarget(@target.getNodeTarget())
    @transmission.respondToQueries()

    expect(@payload.deliver).to.have.been
      .calledWith(sinon.match.same(@target))
