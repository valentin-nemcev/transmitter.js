'use strict'



CompositeBindingSourcePart = require 'binder/binding/composite_source_part'


describe 'CompositeBindingSourcePart', ->

  class MessageStub
    getChain: ->

  class MessageChainStub
    getMessageSentFrom: ->


  beforeEach ->
    @source = {}
    @source.bindTarget = sinon.spy()
    @part = new CompositeBindingSourcePart(@source)
    @compositeTarget = new class CompositeTargetStub
      sendMerged: ->
    @part.bindCompositeTarget(@compositeTarget)


  it 'should bind itself to message sender', ->
    expect(@source.bindTarget).to.have.been.calledWithSame(@part)


  it 'should provide its source as a key', ->
    expect(@part.getSourceKey()).to.equal(@source)


  it 'should provide message in chain sent from source', ->
    message = new MessageStub
    messageChain = new MessageChainStub
    sinon.stub(messageChain, 'getMessageSentFrom')
      .withArgs(sinon.match.same(@source))
      .returns(message)

    expect(@part.getSentMessage(messageChain)).to.equal(message)


  it 'should notify its composite target when message is sent to it', ->
    message = new MessageStub
    messageChain = new MessageChainStub
    sinon.stub(message, 'getChain').returns(messageChain)
    sinon.spy(@compositeTarget, 'sendMerged')
    @part.send(message)

    expect(@compositeTarget.sendMerged)
      .to.have.been.calledWithSame(messageChain)
