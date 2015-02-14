'use strict'


OutgoingBindings = require 'binder/node/outgoing_bindings'


describe 'OutgoingBindings', ->

  describe 'with attached bindings', ->

    beforeEach ->
      @binding1 = {send: sinon.spy()}
      @binding2 = {send: sinon.spy()}
      @outgoingBindings = new OutgoingBindings
      @outgoingBindings.attach(@binding1)
      @outgoingBindings.attach(@binding2)


    it 'should send message to attached bindings', ->
      message = {}
      @outgoingBindings.send(message)
      expect(@binding1.send).to.have.been.calledWith(message)
      expect(@binding2.send).to.have.been.calledWith(message)


