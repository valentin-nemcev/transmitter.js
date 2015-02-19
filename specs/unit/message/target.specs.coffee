'use strict'


MessageTarget = require 'binder/message/target'


describe 'MessageTarget', ->

  it 'should delegate to message when message is sent to it', ->
    @node = {}
    @target = new MessageTarget(@node)
    message = {deliver: sinon.spy()}

    @target.send(message)

    expect(message.deliver).to.have.been.calledWithSame(@node)

