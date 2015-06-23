'use strict'

SourceNode = require 'transmitter/nodes/source_node'
SimpleChannel = require 'transmitter/channels/simple_channel'
Transmission = require 'transmitter/transmission/transmission'
Message = require 'transmitter/transmission/message'
ConnectionPayload = require 'transmitter/payloads/connection'

Transmitter = require 'transmitter'

class DirectionStub
  inspect: -> '.'
  matches: (other) -> this == other
  reverse: -> new DirectionStub()

class StubPayload
  inspect: -> 'stub()'

class NodeStub extends SourceNode
  createResponsePayload: -> new StubPayload()

class TargetStub
  receiveMessage: ->


describe 'Message merging', ->

  before ->
    @target = new TargetStub()
    sinon.spy(@target, 'receiveMessage')

    @transmission = new Transmission()
    @directionStub = new DirectionStub()

    @passivePayload = new StubPayload()
    @activeSource = new NodeStub()
    @passiveSource = new NodeStub()
    sinon.stub(@passiveSource, 'createResponsePayload')
      .returns(@passivePayload)

    @compositeSource = new SimpleChannel()
      .inDirection @directionStub
      .createMergingSource([@activeSource, @passiveSource])

    @compositeSource.setTarget(@target)
    Transmitter.startTransmission (tr) =>
      tr.createInitialConnectionMessage(ConnectionPayload.connect())
        .sendToConnection(@compositeSource)


  specify 'when one active source have sent message', ->
    @activePayload = new StubPayload()
    @message1 = new Message(@transmission, @activePayload,
      {direction: @directionStub, precedence: 0})

    @message1.sendFromNodeToNodeSource(@activeSource,
      @activeSource.getNodeSource())


  specify 'then nothing is sent', ->
    expect(@target.receiveMessage).to.not.have.been.called


  specify 'when queries got responses', ->
    @transmission.respond()


  specify 'then merged message is sent', ->
    Message = @message1.constructor
    expect(@target.receiveMessage)
      .to.have.been.calledWith(sinon.match.instanceOf(Message))


  specify 'and merged message payload contains source payloads', ->

    mergedMessage = @target.receiveMessage.firstCall.args[0]
    mergedPayload = mergedMessage.payload


    expect(mergedPayload.getAt(@activeSource)).to.equal(@activePayload)
    expect(mergedPayload.getAt(@passiveSource)).to.equal(@passivePayload)
