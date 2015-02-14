'use strict'


MessageSource = require 'binder/message/source'


describe 'MessageSource', ->

  describe 'with attached bindings', ->

    beforeEach ->
      @binding1 = {send: sinon.spy()}
      @binding2 = {send: sinon.spy()}
      @messageSource = new MessageSource
      @messageSource.attachOutgoingBinding(@binding1)
      @messageSource.attachOutgoingBinding(@binding2)


    it 'should send message to attached bindings', ->
      message = {}
      @messageSource.send(message)
      expect(@binding1.send).to.have.been.calledWith(message)
      expect(@binding2.send).to.have.been.calledWith(message)


