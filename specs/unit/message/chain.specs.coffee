'use strict'


MessageChain = require 'binder/message/chain'


class MessageStub
  setChain: ->

class QueryQueueStub
  addSenderWithChain: ->


describe 'MessageChain', ->

  beforeEach ->
    @queryQueue = new QueryQueueStub()
    @chain = new MessageChain({@queryQueue})


  it 'should provide message sent from given sender', ->
    @message1 = new MessageStub
    @message2 = new MessageStub
    @sender1 = {}
    @sender2 = {}

    @chain.addMessageFrom(@message1, @sender1)
    @chain.addMessageFrom(@message2, @sender2)

    expect(@chain.getMessageFrom(@sender1)).to.equal(@message1)
    expect(@chain.getMessageFrom(@sender2)).to.equal(@message2)


  it 'should add senders to query queue', ->
    sender = new class SenderStub
    sinon.spy(@queryQueue, 'addSenderWithChain')

    @chain.addToQueryQueue(sender)

    expect(@queryQueue.addSenderWithChain)
      .to.have.been.calledWith(
        sinon.match.same(sender),
        sinon.match.same(@chain)
      )
