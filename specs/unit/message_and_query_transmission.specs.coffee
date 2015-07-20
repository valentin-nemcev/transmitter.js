'use strict'

SourceNode = require 'transmitter/nodes/source_node'
TargetNode = require 'transmitter/nodes/target_node'
SimpleChannel = require 'transmitter/channels/simple_channel'

Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'
Transmission = require 'transmitter/transmission/transmission'

Transmitter = require 'transmitter'


class DirectionStub
  matches: (other) -> this == other
  reverse: -> new DirectionStub()

class StubPayload
  deliver: ->

class PrecedenceStub
  constructor: (@direction) ->
  directionMatches: (direction) -> direction == @direction
  getFinal: -> null

class NodeSourceStub extends SourceNode
  createResponsePayload: -> new StubPayload()

class NodeTargetStub extends TargetNode
  acceptPayload: (payload) ->
    payload.deliver(this)
    return this


describe 'Message and query transmission', ->

  beforeEach ->
    @source = new NodeSourceStub()
    @target = new NodeTargetStub()
    @direction = new DirectionStub()
    @precedence = new PrecedenceStub(@direction)

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
    @message = new Message(@transmission, @payload, {@precedence})

    @message.sendFromNodeToNodeSource(@source, @source.getNodeSource())

    expect(@payload.deliver).to.have.been
      .calledWith(sinon.match.same(@target))


  it 'transmits query from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    sinon.stub(@source, 'createResponsePayload').returns(@payload)
    @query = new Query(@transmission, {@precedence})

    @query.sendFromNodeToNodeTarget(@target, @target.getNodeTarget())
    @transmission.respond()

    expect(@payload.deliver).to.have.been
      .calledWith(sinon.match.same(@target))
