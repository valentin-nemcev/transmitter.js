'use strict'



CompositeBindingSourcePart = require 'binder/binding/composite_source_part'


describe 'CompositeBindingSourcePart', ->

  beforeEach ->
    @source = {}
    @source.bindTarget = sinon.spy()
    @part = new CompositeBindingSourcePart(@source)
    @compositeTarget = new class CompositeTargetStub
    @part.bindCompositeTarget(@compositeTarget)


  it 'should bind itself to message sender', ->
    expect(@source.bindTarget).to.have.been.calledWithSame(@part)


  it 'should provide its source as a key', ->
    expect(@part.getSourceKey()).to.equal(@source)


  it 'should get message in chain sent from source', ->
    @messageChain = {}
    @message = {}
    @messageChain.getMessageSentFrom = sinon.stub()
    @messageChain.getMessageSentFrom
      .withArgs(sinon.match.same(@source))
      .returns(@message)

    expect(@part.getSentMessage(@messageChain)).to.equal(@message)


  it 'should notify its composite target when message is sent to it', ->
    message = {}
    @compositeTarget.receive = sinon.spy()
    @part.send(message)

    expect(@compositeTarget.receive).to.have.been.calledWithSame(message)
