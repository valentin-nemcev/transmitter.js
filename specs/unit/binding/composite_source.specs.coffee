'use strict'


CompositeBindingSource = require 'binder/binding/composite_source'


describe 'CompositeBindingSource', ->

  beforeEach ->
    @part1 =
      bindCompositeTarget: ->
    @part2 =
      bindCompositeTarget: ->
    @mergeResult = {mergeResult: yes}
    @merge = sinon.stub().returns(@mergeResult)
    @compositeSource = new CompositeBindingSource([@part1, @part2], {@merge})
    @target = send: sinon.spy()
    @compositeSource.bindTarget(@target)

    @messageChain = new class MessageChainStub
    @messageFromPart1 = {getChain: => @messageChain}
    @messageFromPart2 = {getChain: => @messageChain}
    @part1SourceKey = {}
    @part2SourceKey = {}
    @part1.getSourceKey = => @part1SourceKey
    @part2.getSourceKey = => @part2SourceKey



  describe 'when some parts have sent their messages', ->

    beforeEach ->
      @part1.getSentMessage = sinon.stub()
      @part1.getSentMessage
        .withArgs(sinon.match.same(@messageChain))
        .returns @messageFromPart1

      @part2.getSentMessage = sinon.stub()
      @part2.getSentMessage.returns null

      @compositeSource.receive(@messageFromPart1)


    it 'should not send anything to merge', ->
      expect(@merge).to.not.have.been.called


  describe 'when all parts have sent their messages', ->

    beforeEach ->
      @part1.getSentMessage = sinon.stub()
      @part1.getSentMessage
        .withArgs(sinon.match.same(@messageChain))
        .returns @messageFromPart1

      @part2.getSentMessage = sinon.stub()
      @part2.getSentMessage
        .withArgs(sinon.match.same(@messageChain))
        .returns @messageFromPart2

      @compositeSource.receive(@messageFromPart1)

      @mergedMessages = @merge.firstCall.args[0]


    it 'should send messages from sources for merge as a map', ->
      expect(Array.from(@mergedMessages.keys()))
        .to.have.members([@part1SourceKey, @part2SourceKey])
      expect(@mergedMessages.get(@part1SourceKey)).to.equal(@messageFromPart1)
      expect(@mergedMessages.get(@part2SourceKey)).to.equal(@messageFromPart2)


    it 'should send merged messages to its target', ->
      expect(@target.send).to.have.been.calledWithSame(@mergeResult)
