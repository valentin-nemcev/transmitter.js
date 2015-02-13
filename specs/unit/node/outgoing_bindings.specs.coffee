'use strict'


OutgoingBindings = require 'binder/node/outgoing_bindings'


describe 'OutgoingBindings', ->

  describe 'with attached bindings', ->

    beforeEach ->
      @binding1 = {propagate: sinon.spy()}
      @binding2 = {propagate: sinon.spy()}
      @outgoingBindings = new OutgoingBindings
      @outgoingBindings.attach(@binding1)
      @outgoingBindings.attach(@binding2)


    it 'should propagate message to attached bindings', ->
      message = {}
      @outgoingBindings.propagate(message)
      expect(@binding1.propagate).to.have.been.calledWith(message)
      expect(@binding2.propagate).to.have.been.calledWith(message)


