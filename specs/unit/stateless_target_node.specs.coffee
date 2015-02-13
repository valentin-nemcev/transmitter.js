'use strict'


StatelessTargetNode = require 'binder/stateless_target_node'


describe 'StatelessTargetNode', ->

  it 'should delegate to message when message is propagated to it', ->
    @node = new StatelessTargetNode
    @node.receive = sinon.spy()
    message = {propagateTo: sinon.spy()}

    @node.propagate(message)

    expect(message.propagateTo).to.have.been.calledWith(@node)
