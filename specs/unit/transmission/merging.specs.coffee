'use strict'

NodeSource = require 'binder/binding/node_source'
CompositeSourceBuilder = require 'binder/binding/composite_source_builder'
Transmission = require 'binder/transmission/transmission'


class NodeStub
  NodeSource.extend(this)

class TargetStub
  receiveMessage: ->

class PayloadStub


describe 'Message merging', ->

  beforeEach ->
    @target = new TargetStub()
    sinon.spy(@target, 'receiveMessage')

    @transmission = new Transmission()


  describe 'without querying', ->

    beforeEach ->
      @source1 = new NodeStub()
      @source2 = new NodeStub()

      @compositeSource = CompositeSourceBuilder.build()
        .withPassivePart(@source1)
        .withPassivePart(@source2)
        .create()

      @compositeSource.bindTarget(@target)


    specify 'when not all sources have sent messages, nothing is sent', ->
      @message1 = @transmission.createMessage(new PayloadStub)
      @message1.sendFromSourceNode(@source1)
      @transmission.respondToQueries()

      expect(@target.receiveMessage).to.not.have.been.called


    describe 'when all source have sent messages', ->

      beforeEach ->
        @payload1 = new PayloadStub()
        @payload2 = new PayloadStub()
        @message1 = @transmission.createMessage(@payload1)
        @message2 = @transmission.createMessage(@payload2)
        @message1.sendFromSourceNode(@source1)
        @message2.sendFromSourceNode(@source2)
        @transmission.respondToQueries()


      specify 'merged message is sent', ->
        Message = @message1.constructor
        expect(@target.receiveMessage)
          .to.have.been.calledWith(sinon.match.instanceOf(Message))


      specify 'merged message payload contains source payloads', ->
        @mergedMessage = @target.receiveMessage.firstCall.args[0]
        @mergedPayload = @mergedMessage.getPayload()

        expect(@mergedPayload.get(@source1)).to.equal(@payload1)
        expect(@mergedPayload.get(@source2)).to.equal(@payload2)


  describe 'with querying', ->

    beforeEach ->
      @passiveSource = new NodeStub()
      @activeSource = new NodeStub()

      @compositeSource = CompositeSourceBuilder.build()
        .withPart(@activeSource)
        .withPassivePart(@passiveSource)
        .create()

      @compositeSource.bindTarget(@target)


    specify 'when only passive sources have sent messages, nothing is sent', ->
      @message1 = @transmission.createMessage(new PayloadStub)
      @message1.sendFromSourceNode(@passiveSource)
      @transmission.respondToQueries()

      expect(@target.receiveMessage).to.not.have.been.called


    describe 'when only active sources have sent messages', ->

      beforeEach ->
        @payload1 = new PayloadStub()
        @payload2 = new PayloadStub()
        @message1 = @transmission.createMessage(@payload1)
        @message1.sendFromSourceNode(@activeSource)
        @transmission.respondToQueries()


      specify 'merged message is sent', ->
        Message = @message1.constructor
        expect(@target.receiveMessage)
          .to.have.been.calledWith(sinon.match.instanceOf(Message))


      specify.skip 'merged message payload contains source payloads', ->
        @mergedMessage = @target.receiveMessage.firstCall.args[0]
        @mergedPayload = @mergedMessage.getPayload()

        expect(@mergedPayload.get(@activeSource)).to.equal(@payload1)
        expect(@mergedPayload.get(@passiveSource)).to.equal(@payload2)


