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
  createResponsePayload: -> new StubPayload()

class NodeTargetStub extends TargetNode
  acceptPayload: (payload) ->
    payload.deliver?(this)
    return this


describe 'Message and query transmission', ->

  beforeEach ->
    @source = new NodeSourceStub()
    @target = new NodeTargetStub()
    @pass = Pass.createMessageDefault()
    @direction = @pass.direction

    Transmitter.startTransmission (tr) =>
      new SimpleChannel()
        .inDirection @direction
        .fromSource @source
        .toTarget @target
        .init(tr)

    @transmission = new Transmission()


  it 'transmits message from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    @message = new Message(@transmission, @payload, {@pass})

    @message.sendFromNodeToNodeSource(@source, @source.getNodeSource())

    expect(@payload.deliver).to.have.been
      .calledWith(sinon.match.same(@target))


  it 'transmits query from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    sinon.stub(@source, 'createResponsePayload').returns(@payload)
    @query = new Query(@transmission, {@pass})

    @query.sendToNode(@target)
    @transmission.respond()

    expect(@payload.deliver).to.have.been
      .calledWith(sinon.match.same(@target))
