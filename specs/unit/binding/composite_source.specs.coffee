'use strict'


CompositeBindingSource = require 'binder/binding/composite_source'

class CompositePartStub
  bindCompositeTarget: ->
  getSourceKey: ->
  getSentMessage: ->
  enquire: ->

class TargetStub
  send: ->

class MessageStub
  sendMergedTo: ->
  sendTo: ->


describe 'CompositeBindingSource', ->

  beforeEach ->
    @part1 = new CompositePartStub
    @part2 = new CompositePartStub

    @mergedMessage = new class MergedMessageStub
    @merge = sinon.stub().returns(@mergedMessage)

    @compositeSource = new CompositeBindingSource([@part1, @part2], {@merge})

    @target = new TargetStub()
    @compositeSource.bindTarget(@target)

    @transmission = new class TransmissionStub
    @messageFromPart1 = new MessageStub
    @messageFromPart2 = new MessageStub
    @part1SourceKey = new class Part1SourceKeyStub
    @part2SourceKey = new class Part2SourceKeyStub
    sinon.stub(@part1, 'getSourceKey').returns(@part1SourceKey)
    sinon.stub(@part2, 'getSourceKey').returns(@part2SourceKey)


  describe 'merges messages from its source parts', ->

    beforeEach ->
      @message = new MessageStub
      sinon.spy(@message, 'sendMergedTo')

      @compositeSource.receive(@message)


    it 'should pass its source part keys to message for merge', ->
      sourceKeysForMerge = @message.sendMergedTo.firstCall.args[0]
      expect(sourceKeysForMerge)
        .to.have.members([@part1SourceKey, @part2SourceKey])


    it 'should send merged message to its target', ->
      mergedMessageTarget = @message.sendMergedTo.firstCall.args[1]
      expect(mergedMessageTarget).to.equal(@target)


  describe 'when some parts have sent their messages', ->

    beforeEach ->
      sinon.stub(@part1, 'getSentMessage')
        .withArgs(sinon.match.same(@transmission))
        .returns @messageFromPart1

      sinon.stub(@part2, 'getSentMessage')
        .returns(null)

      @compositeSource.sendMerged(@transmission)


    it 'should not send anything to merge', ->
      expect(@merge).to.not.have.been.called


  describe 'when all parts have sent their messages', ->

    beforeEach ->
      sinon.stub(@part1, 'getSentMessage')
        .withArgs(sinon.match.same(@transmission))
        .returns @messageFromPart1

      sinon.stub(@part2, 'getSentMessage')
        .withArgs(sinon.match.same(@transmission))
        .returns @messageFromPart2


    it 'should send messages from sources for merge as a map', ->
      @compositeSource.sendMerged(@transmission)

      @mergedMessages = @merge.firstCall.args[0]
      expect(Array.from(@mergedMessages.keys()))
        .to.have.members([@part1SourceKey, @part2SourceKey])
      expect(@mergedMessages.get(@part1SourceKey)).to.equal(@messageFromPart1)
      expect(@mergedMessages.get(@part2SourceKey)).to.equal(@messageFromPart2)


    it 'should send merged messages to its target', ->
      sinon.spy(@target, 'send')

      @compositeSource.sendMerged(@transmission)

      expect(@target.send).to.have.been.calledWithSame(@mergedMessage)


  describe 'when enquired', ->

    it 'should enquire source its source parts', ->
      sinon.spy(@part1, 'enquire')
      sinon.spy(@part2, 'enquire')

      @compositeSource.enquire(@transmission)

      expect(@part1.enquire).to.have.been.calledWithSame(@transmission)
      expect(@part2.enquire).to.have.been.calledWithSame(@transmission)
