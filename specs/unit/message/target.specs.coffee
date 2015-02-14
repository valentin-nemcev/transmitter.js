'use strict'


MessageTarget = require 'binder/message/target'


describe 'MessageTarget', ->

  it 'should delegate to message when message is sent to it', ->
    @node = {}
    @target = new MessageTarget(@node)
    message = {sendTo: sinon.spy()}

    @target.send(message)

    expect(message.sendTo).to.have.been.calledWith(@node)

