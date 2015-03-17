'use strict'


CompositeBindingSourcePart = require 'binder/binding/composite_source_part'


class SourceStub
  bindTarget: ->
  enquire: ->

class MessageStub
  enquireForMerge: ->

class QueryStub

class MessageChainStub
  getMessageFrom: ->

class CompositeTargetStub
  receive: ->
  enquire: ->


describe 'CompositeBindingSourcePart', ->

  beforeEach ->
    @source = new SourceStub
    @sourceNode = new class SourceNodeStub
    @part = new CompositeBindingSourcePart(@sourceNode, @source)


  it 'should bind itself to message sender', ->
    sinon.spy(@source, 'bindTarget')
    compositeTarget = new CompositeTargetStub()
    @part.bindCompositeTarget(compositeTarget)

    expect(@source.bindTarget).to.have.been.calledWithSame(@part)


  it 'should provide its source as a key', ->
    expect(@part.getSourceKey()).to.equal(@sourceNode)


  it 'should pass enquiry to its source', ->
    query = new QueryStub
    sinon.spy(@source, 'enquire')

    @part.enquire(query)

    expect(@source.enquire).to.have.been.calledWithSame(query)


  describe 'after receiving a message', ->

    beforeEach ->
      @message = new MessageStub


    it 'should merge and send it to composite target', ->
      @compositeTarget = new CompositeTargetStub()
      @part.bindCompositeTarget(@compositeTarget)
      sinon.spy(@compositeTarget, 'receive')

      @part.receive(@message)

      expect(@compositeTarget.receive)
        .to.have.been.calledWithSame(@message)


    it 'should enquire target for merge when it initiates merge', ->
      @part = new CompositeBindingSourcePart(@sourceNode, @source, initiatesMerge: yes)
      @compositeTarget = new CompositeTargetStub()
      @part.bindCompositeTarget(@compositeTarget)
      sinon.spy(@message, 'enquireForMerge')

      @part.receive(@message)

      expect(@message.enquireForMerge)
        .to.have.been.calledWithSame(@compositeTarget)


    it "should not enquire target for merge when it doesn't initiate merge", ->
      @part = new CompositeBindingSourcePart(@sourceNode, @source, initiatesMerge: no)
      @compositeTarget = new CompositeTargetStub()
      @part.bindCompositeTarget(@compositeTarget)
      sinon.spy(@message, 'enquireForMerge')

      @part.receive(@message)

      expect(@message.enquireForMerge).to.not.have.been.called


