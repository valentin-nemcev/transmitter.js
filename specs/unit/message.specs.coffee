'use strict'


Message = require 'binder/message'


class MessageChainStub
  addMessageFrom: ->
  getMessageFrom: ->

class MessageSenderStub
  sendMessage: ->

class MessagePayloadStub
  deliver: ->

class MessageTargetStub
  send: ->

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


  describe 'merges messages from multiple nodes', ->
    beforeEach ->
      @target = new MessageTargetStub
      sinon.spy(@target, 'send')


    describe 'when not all nodes have sent their messages', ->

      beforeEach ->


      it 'should not send anything to target', ->
        sourceKeys = undefined

        @message.sendMergedTo(sourceKeys, @messageChain)

        expect(@target.send).to.not.have.been.called
