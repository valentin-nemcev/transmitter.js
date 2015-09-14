'use strict'

SourceNode = require 'transmitter/nodes/source_node'
TargetNode = require 'transmitter/nodes/target_node'
SimpleChannel = require 'transmitter/channels/simple_channel'

Pass = require 'transmitter/transmission/pass'
Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'
Transmission = require 'transmitter/transmission/transmission'

Transmitter = require 'transmitter'


class DirectionStub
  matches: (other) -> this == other
  reverse: -> new DirectionStub()

class StubPayload
  inspect: -> 'stub()'
  deliver: ->

class NodeSourceStub extends SourceNode
  createResponsePayload: (payload) -> payload

class NodeTargetStub extends TargetNode
  acceptPayload: (payload) ->
    payload.deliver?(this)
    return this


describe 'Message and query transmission', ->

  beforeEach ->
    @source = new NodeSourceStub()
    @target = new NodeTargetStub()


  it 'transmits message from source to target', ->
    Transmitter.startTransmission (tr) =>
      new SimpleChannel()
        .inBackwardDirection()
        .fromSource @source
        .toTarget @target
        .init(tr)

    @transmission = new Transmission()

    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    @transmission.originateMessage(@source, @payload)

    expect(@payload.deliver).to.have.been
      .calledWith(sinon.match.same(@target))


  it 'transmits query from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    sinon.stub(@source, 'createResponsePayload').returns(@payload)

    Transmitter.startTransmission (tr) =>
      new SimpleChannel()
        .inForwardDirection()
        .fromSource @source
        .toTarget @target
        .init(tr)

    @transmission = new Transmission()

    @transmission.originateQuery(@target)
    @transmission.respond()

    expect(@payload.deliver).to.have.been
      .calledWith(sinon.match.same(@target))
