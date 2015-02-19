'use strict'


MessageSender = require 'binder/message/sender'


describe 'MessageSender', ->

  describe 'with bound targets', ->

    beforeEach ->
      @binding1 = {send: sinon.spy()}
      @binding2 = {send: sinon.spy()}
      @messageSource = new MessageSender
      @messageSource.bindTarget(@binding1)
      @messageSource.bindTarget(@binding2)


    it 'should send message to bound targets', ->
      message = {}
      @messageSource.send(message)
      expect(@binding1.send).to.have.been.calledWithSame(message)
      expect(@binding2.send).to.have.been.calledWithSame(message)
