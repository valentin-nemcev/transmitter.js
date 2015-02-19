'use strict'


MessageSource = require 'binder/message/source'


describe 'MessageSource', ->

  describe 'with bound targets', ->

    beforeEach ->
      @binding1 = {send: sinon.spy()}
      @binding2 = {send: sinon.spy()}
      @messageSource = new MessageSource
      @messageSource.bindTarget(@binding1)
      @messageSource.bindTarget(@binding2)


    it 'should send message to bound targets', ->
      message = {}
      @messageSource.send(message)
      expect(@binding1.send).to.have.been.calledWithSame(message)
      expect(@binding2.send).to.have.been.calledWithSame(message)
