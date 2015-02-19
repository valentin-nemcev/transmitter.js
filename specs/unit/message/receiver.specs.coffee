'use strict'


MessageReceiver = require 'binder/message/receiver'


describe 'MessageReceiver', ->

  it 'should delegate to message when message is sent to it', ->
    @node = {}
    @target = new MessageReceiver(@node)
    message = {deliver: sinon.spy()}

    @target.send(message)

    expect(message.deliver).to.have.been.calledWithSame(@node)

