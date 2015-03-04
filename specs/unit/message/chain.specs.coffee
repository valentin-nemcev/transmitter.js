'use strict'


MessageChain = require 'binder/message/chain'


class MessageStub

class NodeStub


describe 'MessageChain', ->

  beforeEach ->
    @chain = new MessageChain()


  it 'should provide message sent from given sender', ->
    @message1 = new MessageStub
    @message2 = new MessageStub
    @node1 = new NodeStub
    @node2 = new NodeStub

    @chain.addMessageFrom(@message1, @node1)
    @chain.addMessageFrom(@message2, @node2)

    expect(@chain.getMessageFrom(@node1)).to.equal(@message1)
    expect(@chain.getMessageFrom(@node2)).to.equal(@message2)


  it 'should add nodes to query queue', ->
    @node1 = new NodeStub
    @node2 = new NodeStub

    @chain.addQueryTo(@node1)
    @chain.addQueryTo(@node2)

