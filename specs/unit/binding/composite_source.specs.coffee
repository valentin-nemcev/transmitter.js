'use strict'


CompositeBindingSource = require 'binder/binding/composite_source'


describe 'CompositeBindingSource', ->

  class CompositePartStub
    bindCompositeTarget: ->
    getSourceKey: ->
    getSentMessage: ->


  beforeEach ->
    @part1 = new CompositePartStub
    @part2 = new CompositePartStub
    @mergedMessage = new class MergedMessageStub
    @merge = sinon.stub().returns(@mergedMessage)
    @compositeSource = new CompositeBindingSource([@part1, @part2], {@merge})
    @target = send: sinon.spy()
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

      @compositeSource.sendMerged(@messageChain)

      @mergedMessages = @merge.firstCall.args[0]


    it 'should send messages from sources for merge as a map', ->
      expect(Array.from(@mergedMessages.keys()))
        .to.have.members([@part1SourceKey, @part2SourceKey])
      expect(@mergedMessages.get(@part1SourceKey)).to.equal(@messageFromPart1)
      expect(@mergedMessages.get(@part2SourceKey)).to.equal(@messageFromPart2)


    it 'should send merged messages to its target', ->
      expect(@target.send).to.have.been.calledWithSame(@mergedMessage)
