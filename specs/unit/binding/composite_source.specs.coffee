'use strict'


CompositeBindingSource = require 'binder/binding/composite_source'


describe 'CompositeBindingSource', ->

  class CompositePartStub
    bindCompositeTarget: ->
    getSourceKey: ->
    getSentMessage: ->
    enquire: ->

  class TargetStub
    send: ->


  beforeEach ->
    @part1 = new CompositePartStub
    @part2 = new CompositePartStub

    @mergedMessage = new class MergedMessageStub
    @merge = sinon.stub().returns(@mergedMessage)

    @compositeSource = new CompositeBindingSource([@part1, @part2], {@merge})

    @target = new TargetStub()
    @compositeSource.bindTarget(@target)

    @messageChain = new class MessageChainStub
    class MessageStub
    @messageFromPart1 = new MessageStub
    @messageFromPart2 = new MessageStub
    @part1SourceKey = {}
    @part2SourceKey = {}
    sinon.stub(@part1, 'getSourceKey').returns(@part1SourceKey)
    sinon.stub(@part2, 'getSourceKey').returns(@part2SourceKey)


  describe 'when some parts have sent their messages', ->

    beforeEach ->
      sinon.stub(@part1, 'getSentMessage')
        .withArgs(sinon.match.same(@messageChain))
        .returns @messageFromPart1

      sinon.stub(@part2, 'getSentMessage')
        .returns(null)

      @compositeSource.sendMerged(@messageChain)


    it 'should not send anything to merge', ->
      expect(@merge).to.not.have.been.called


  describe 'when all parts have sent their messages', ->

    beforeEach ->
      sinon.stub(@part1, 'getSentMessage')
        .withArgs(sinon.match.same(@messageChain))
        .returns @messageFromPart1

      sinon.stub(@part2, 'getSentMessage')
        .withArgs(sinon.match.same(@messageChain))
        .returns @messageFromPart2


    it 'should send messages from sources for merge as a map', ->
      @compositeSource.sendMerged(@messageChain)

      @mergedMessages = @merge.firstCall.args[0]
      expect(Array.from(@mergedMessages.keys()))
        .to.have.members([@part1SourceKey, @part2SourceKey])
      expect(@mergedMessages.get(@part1SourceKey)).to.equal(@messageFromPart1)
      expect(@mergedMessages.get(@part2SourceKey)).to.equal(@messageFromPart2)


    it 'should send merged messages to its target', ->
      sinon.spy(@target, 'send')

      @compositeSource.sendMerged(@messageChain)

      expect(@target.send).to.have.been.calledWithSame(@mergedMessage)


  describe 'when enquired', ->

    it 'should enquire source its source parts', ->
      sinon.spy(@part1, 'enquire')
      sinon.spy(@part2, 'enquire')

      @compositeSource.enquire(@messageChain)

      expect(@part1.enquire).to.have.been.calledWithSame(@messageChain)
      expect(@part2.enquire).to.have.been.calledWithSame(@messageChain)
