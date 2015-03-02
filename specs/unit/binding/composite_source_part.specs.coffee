'use strict'



CompositeBindingSourcePart = require 'binder/binding/composite_source_part'


describe 'CompositeBindingSourcePart', ->

  class SourceStub
    bindTarget: ->
    enquire: ->

  class MessageStub
    getChain: ->

  class MessageChainStub
    getMessageFrom: ->

  class CompositeTargetStub
    sendMerged: ->
    enquire: ->


  beforeEach ->
    @source = new SourceStub
    @part = new CompositeBindingSourcePart(@source)


  it 'should bind itself to message sender', ->
    sinon.spy(@source, 'bindTarget')
    compositeTarget = new CompositeTargetStub()
    @part.bindCompositeTarget(compositeTarget)

    expect(@source.bindTarget).to.have.been.calledWithSame(@part)


  it 'should provide its source as a key', ->
    expect(@part.getSourceKey()).to.equal(@source)


  it 'should provide message in chain sent from source', ->
    message = new MessageStub
    messageChain = new MessageChainStub
    sinon.stub(messageChain, 'getMessageFrom')
      .withArgs(sinon.match.same(@source))
      .returns(message)

    expect(@part.getSentMessage(messageChain)).to.equal(message)


  it 'should pass enquiry to its source', ->
    messageChain = new MessageChainStub
    sinon.spy(@source, 'enquire')

    @part.enquire(messageChain)

    expect(@source.enquire).to.have.been.calledWithSame(messageChain)


  describe 'after receiving a message', ->

    beforeEach ->
      @message = new MessageStub
      @messageChain = new MessageChainStub
      sinon.stub(@message, 'getChain').returns(@messageChain)


    it 'should notify its composite target when message is sent to it', ->
      compositeTarget = new CompositeTargetStub()
      @part.bindCompositeTarget(compositeTarget)
      sinon.spy(compositeTarget, 'sendMerged')

      @part.send(@message)

      expect(compositeTarget.sendMerged)
        .to.have.been.calledWithSame(@messageChain)


    it 'should enquire composite target when it initiates merge', ->
      part = new CompositeBindingSourcePart(@source, initiatesMerge: yes)
      compositeTarget = new CompositeTargetStub()
      part.bindCompositeTarget(compositeTarget)
      sinon.spy(compositeTarget, 'enquire')

      part.send(@message)

      expect(compositeTarget.enquire)
        .to.have.been.calledWithSame(@messageChain)


    it 'should not enquire composite target when it doesnt initiate merge', ->
      part = new CompositeBindingSourcePart(@source, initiatesMerge: no)
      compositeTarget = new CompositeTargetStub()
      part.bindCompositeTarget(compositeTarget)
      sinon.spy(compositeTarget, 'enquire')

      part.send(@message)

      expect(compositeTarget.enquire).to.not.have.been.called
