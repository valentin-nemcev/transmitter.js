'use strict'

NodeSource = require 'binder/binding/node_source'
CompositeSourceBuilder = require 'binder/binding/composite_source_builder'
Transmission = require 'binder/transmission/transmission'


class StubPayload

class NodeStub
  NodeSource.extend(this)
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

    @compositeSource = new CompositeSourceBuilder()
      .withPart(@activeSource)
      .withPart(@passiveSource)
      .build()

    @compositeSource.bindTarget(@target)


  specify 'when one active source have sent message', ->
    @activePayload = new StubPayload()
    @message1 = @transmission.createMessage(@activePayload)

    @message1.sendFromSourceNode(@activeSource)


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


    expect(mergedPayload.get(@activeSource)).to.equal(@activePayload)
    expect(mergedPayload.get(@passiveSource)).to.equal(@passivePayload)
