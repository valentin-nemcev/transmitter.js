'use strict'

SourceNode = require 'transmitter/nodes/source_node'
SimpleChannel = require 'transmitter/channels/simple_channel'
Transmission = require 'transmitter/transmission/transmission'
Message = require 'transmitter/transmission/message'
Pass = require 'transmitter/transmission/pass'

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
    @pass = Pass.createMessageDefault()

    @passivePayload = new StubPayload()
    @activeSource = new NodeStub()
    @passiveSource = new NodeStub()
    sinon.stub(@passiveSource, 'createResponsePayload')
      .returns(@passivePayload)

    @compositeSource = new SimpleChannel()
      .inDirection @pass.direction
      .createMergingSource([@activeSource, @passiveSource])

    @compositeSource.setTarget(@target)
    message = @transmission.createInitialConnectionMessage()
    @compositeSource.connect(message)
    message.sendToTargetPoints()


  specify 'when one active source have sent message', ->
    @activePayload = new StubPayload()
    @message1 = new Message(@transmission, @activePayload, {@pass})

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


  specify 'and merged message has source payloads', ->
    mergedMessage = @target.receiveMessage.firstCall.args[0]
    mergedPayload = mergedMessage.payload

    expect(mergedPayload.get(@activeSource)).to.equal(@activePayload)
    expect(mergedPayload.get(@passiveSource)).to.equal(@passivePayload)
