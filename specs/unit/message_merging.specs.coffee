'use strict'

SourceNode = require 'transmitter/nodes/source_node'
SimpleChannel = require 'transmitter/channels/simple_channel'
Transmission = require 'transmitter/transmission/transmission'
Message = require 'transmitter/transmission/message'
ConnectionPayload = require 'transmitter/payloads/connection'

Transmitter = require 'transmitter'

class StubPayload

class NodeStub extends SourceNode
  createResponsePayload: -> new StubPayload()

class TargetStub
  receiveMessage: ->


describe 'Message merging', ->

  before ->
    @target = new TargetStub()
    sinon.spy(@target, 'receiveMessage')

    @transmission = new Transmission()

    @passivePayload = new StubPayload()
    @activeSource = new NodeStub()
    @passiveSource = new NodeStub()
    sinon.stub(@passiveSource, 'createResponsePayload')
      .returns(@passivePayload)

    @compositeSource = new SimpleChannel()
      .createMergingSource([@activeSource, @passiveSource])

    @compositeSource.setTarget(@target)
    Transmitter.startTransmission (tr) =>
      tr.createInitialConnectionMessage(ConnectionPayload.connect())
        .sendToConnection(@compositeSource)


  specify 'when one active source have sent message', ->
    @activePayload = new StubPayload()
    @message1 = new Message(@transmission, @activePayload)

    @message1.sendToNodeSource(@activeSource.getNodeSource())


  specify 'then nothing is sent', ->
    expect(@target.receiveMessage).to.not.have.been.called


  specify 'when queries got responses', ->
    @transmission.respondToQueries()


  specify 'then merged message is sent', ->
    Message = @message1.constructor
    expect(@target.receiveMessage)
      .to.have.been.calledWith(sinon.match.instanceOf(Message))


  specify 'and merged message payload contains source payloads', ->
    @transmission.respondToQueries()

    mergedMessage = @target.receiveMessage.firstCall.args[0]
    mergedPayload = mergedMessage.getPayload()


    expect(mergedPayload.getAt(@activeSource)).to.equal(@activePayload)
    expect(mergedPayload.getAt(@passiveSource)).to.equal(@passivePayload)
