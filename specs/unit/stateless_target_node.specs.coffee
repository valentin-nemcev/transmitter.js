'use strict'


StatelessTargetNode = require 'binder/stateless_target_node'


describe 'StatelessTargetNode', ->

  it 'should delegate to message when message is sent to it', ->
    @node = new StatelessTargetNode
    @node.receive = sinon.spy()
    message = {sendTo: sinon.spy()}

    @node.send(message)

    expect(message.sendTo).to.have.been.calledWith(@node)
