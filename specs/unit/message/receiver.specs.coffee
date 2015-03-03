'use strict'


MessageReceiver = require 'binder/message/receiver'


class MessageStub
  sendToNode: ->


class NodeStub

describe 'MessageReceiver', ->

  it 'should delegate to message when message is sent to it', ->
    @node = new NodeStub
    @target = new MessageReceiver(@node)
    message = new MessageStub
    sinon.spy(message, 'sendToNode')

    @target.send(message)

    expect(message.sendToNode).to.have.been.calledWithSame(@node)

