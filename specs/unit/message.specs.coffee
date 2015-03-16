'use strict'


Message = require 'binder/transmission/message'


class MessageChainStub
  addMessageFrom: ->
  getMessageFrom: ->
  createQuery: ->
  mergeMessagesFrom: ->

class MessageSenderStub
  sendMessage: ->

class MessagePayloadStub
  deliver: ->

class MessageStub
  sendTo: ->

class MessageTargetStub
  receive: ->
  enquire: ->


describe 'Message', ->

  beforeEach ->
    @messageChain = new MessageChainStub
    @messageSender = new MessageSenderStub
    @message = new Message(@messageChain)
    @payload = new MessagePayloadStub
    @message.setPayload(@payload)


  describe 'when sent from sender', ->

    it 'should add itself to message chain', ->
      sinon.spy(@messageChain, 'addMessageFrom')

      @message.sendFrom(@messageSender)

      expect(@messageChain.addMessageFrom).to.have.been.calledWith(
        sinon.match.same(@message),
        sinon.match.same(@messageSender),
      )


    it 'should pass itself for sending to message sender', ->
      sinon.spy(@messageSender, 'sendMessage')

      @message.sendFrom(@messageSender)

      expect(@messageSender.sendMessage).to.have.been.calledWithSame(@message)


    it 'should add itself to message chain before passing itself to sender', ->
      sinon.spy(@messageChain, 'addMessageFrom')
      sinon.spy(@messageSender, 'sendMessage')

      @message.sendFrom(@messageSender)

      expect(@messageChain.addMessageFrom)
        .to.have.been.calledBefore(@messageSender.sendMessage)


  describe 'when copied with transformed payload', ->

    beforeEach ->
      @transformedPayload = new MessagePayloadStub
      @transform = sinon.stub()
      @transform
        .withArgs(sinon.match.same(@payload))
        .returns(@transformedPayload)


    it 'should have payload returned from transform function', ->
      messageCopy = @message.copyWithTransformedPayload(@transform)

      expect(messageCopy.payload).to.equal(@transformedPayload)


    it 'should have same chain as the original', ->
      messageCopy = @message.copyWithTransformedPayload(@transform)

      expect(messageCopy.chain).to.equal(@message.chain)


  describe 'when sent to node', ->

    it 'should deliver its payload', ->
      targetNode = new class TargetNodeStub
      sinon.spy(@payload, 'deliver')
      @message.sendToNode(targetNode)

      expect(@payload.deliver).to.have.been.calledWithSame(targetNode)


  describe.skip 'merges messages from multiple nodes', ->

    beforeEach ->
      @sourceKeys = new class SourceKeysStub

      @target = new MessageTargetStub

    describe 'creates a copy of itself with merged payload', ->

      beforeEach ->
        sinon.stub(@message, 'copyWithPayload')
          .withArgs(@mergedPayload)
          .returns(@mergedMessage)

      it 'sends it to provided target', ->
        sinon.spy(@mergedMessage, 'sendTo')

        @message.sendMergedTo(@sourceKeys, @target)

        expect(@mergedMessage.sendTo).to.have.been.calledWithSame(@target)


  describe 'sends query for merge', ->
    beforeEach ->
      @target = new MessageTargetStub
      sinon.spy(@target, 'enquire')


    it 'should create a query and send it to source', ->
      @mergeQuery = new class QueryStub
      sinon.stub(@messageChain, 'createQuery').returns(@mergeQuery)

      @message.enquireForMerge(@target)

      expect(@target.enquire).to.have.been.calledWithSame(@mergeQuery)
