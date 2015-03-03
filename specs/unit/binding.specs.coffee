'use strict'


Binding = require 'binder/binding'


class SourceStub
  bindTarget: ->

class TargetStub
  send: ->

class MessageStub
  copyWithTransformedPayload: ->


describe 'Binding', ->

  beforeEach ->
    @source = new SourceStub
    @target = new TargetStub


  describe 'when bound', ->

    beforeEach ->
      @binding = new Binding({transform: (arg) -> arg})


    it 'should add itself as target to its source', ->
      sinon.spy(@source, 'bindTarget')

      @binding.bindSourceTarget(@source, @target)

      expect(@source.bindTarget).to.have.been.calledWithSame(@binding)


  describe 'when sending message with transform function', ->

    beforeEach ->
      @transform = ->
      @binding = new Binding({@transform})
      @binding.bindSourceTarget(@source, @target)
      sinon.spy(@target, 'send')


    it 'should send message copy with transformed payload', ->
      message = new MessageStub
      messageWithTransformedPayload = new MessageStub
      sinon.stub(message, 'copyWithTransformedPayload')
        .withArgs(sinon.match.same(@transform))
        .returns(messageWithTransformedPayload)

      @binding.send(message)

      expect(@target.send)
        .to.have.been.calledWithSame(messageWithTransformedPayload)
