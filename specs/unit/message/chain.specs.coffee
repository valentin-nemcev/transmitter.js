'use strict'


MessageChain = require 'binder/message/chain'


describe 'MessageChain', ->

  class MessageStub
    setChain: ->


  beforeEach ->
    @chain = new MessageChain()

  it 'should provide message sent from given sender', ->
    @message1 = new MessageStub
    @message2 = new MessageStub
    @sender1 = {}
    @sender2 = {}

    @chain.messageSent(@message1, from: @sender1)
    @chain.messageSent(@message2, from: @sender2)

    expect(@chain.getMessageSentFrom(@sender1)).to.equal(@message1)
    expect(@chain.getMessageSentFrom(@sender2)).to.equal(@message2)
