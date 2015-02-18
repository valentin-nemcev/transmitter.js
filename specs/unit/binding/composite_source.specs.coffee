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


  describe 'when merging message from its parts', ->

    beforeEach ->
      @messageFromPart1 = {}
      @messageFromPart2 = {}
      @part1SourceKey = {}
      @part2SourceKey = {}
      @part1.enquire = => @messageFromPart1
      @part2.enquire = => @messageFromPart2
      @part1.getSourceKey = => @part1SourceKey
      @part2.getSourceKey = => @part2SourceKey

      @compositeSource.sendMerged()

      @mergedMessages = @merge.firstCall.args[0]


    it 'should pass combined messages from sources for merge as a map', ->
      expect(Array.from(@mergedMessages.keys()))
        .to.have.members([@part1SourceKey, @part2SourceKey])
      expect(@mergedMessages.get(@part1SourceKey)).to.equal(@messageFromPart1)
      expect(@mergedMessages.get(@part2SourceKey)).to.equal(@messageFromPart2)


    it 'should send merged message to its target', ->
      expect(@target.send).to.have.been.calledWithSame(@mergeResult)
