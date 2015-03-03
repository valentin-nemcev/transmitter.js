'use strict'


MessageSender = require 'binder/message/sender'


class TargetStub
  send: ->


class MessageChainStub
  addToQueryQueue: ->


class MessageStub


describe 'MessageSender', ->

  beforeEach ->
    @messageSource = new MessageSender()

  describe 'with bound targets', ->

    beforeEach ->
      @target1 = new TargetStub()
      @target2 = new TargetStub()
      @messageSource.bindTarget(@target1)
      @messageSource.bindTarget(@target2)


    it 'should send message to bound targets', ->
      sinon.spy(@target1, 'send')
      sinon.spy(@target2, 'send')
      message = new MessageStub

      @messageSource.sendMessage(message)

      expect(@target1.send).to.have.been.calledWithSame(message)
      expect(@target2.send).to.have.been.calledWithSame(message)


  describe 'when enquired', ->

    it 'should add itself to query queue', ->
      messageChain = new MessageChainStub
      sinon.spy(messageChain, 'addToQueryQueue')

      @messageSource.enquire(messageChain)

      expect(messageChain.addToQueryQueue)
        .to.have.been.calledWithSame(@messageSource)
