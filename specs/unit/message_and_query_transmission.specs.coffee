'use strict'

SourceNode = require 'transmitter/nodes/source_node'
TargetNode = require 'transmitter/nodes/target_node'
SimpleChannel = require 'transmitter/channels/simple_channel'

Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'
Transmission = require 'transmitter/transmission/transmission'

Transmitter = require 'transmitter'


class StubPayload
  deliverToTargetNode: ->

class NodeSourceStub extends SourceNode
  createResponsePayload: -> new StubPayload()

class NodeTargetStub extends TargetNode


describe 'Message and query transmission', ->

  beforeEach ->
    @source = new NodeSourceStub()
    @target = new NodeTargetStub()

    Transmitter.startTransmission (tr) =>
      new SimpleChannel()
        .fromSource @source
        .toTarget @target
        .connect(tr)

    @transmission = new Transmission()


  it 'transmits message from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliverToTargetNode')
    @message = new Message(@transmission, @payload)

    @message.sendToNodeSource(@source.getNodeSource())

    expect(@payload.deliverToTargetNode).to.have.been
      .calledWith(sinon.match.same(@target))


  it 'transmits query from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliverToTargetNode')
    sinon.stub(@source, 'createResponsePayload').returns(@payload)
    @query = new Query(@transmission)

    @query.sendToNodeTarget(@target.getNodeTarget())
    @transmission.respondToQueries()

    expect(@payload.deliverToTargetNode).to.have.been
      .calledWith(sinon.match.same(@target))
