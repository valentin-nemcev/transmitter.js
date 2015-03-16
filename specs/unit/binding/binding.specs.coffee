'use strict'


Binding = require 'binder/binding/binding'


class SourceStub
  bindTarget: ->
  enquire: ->

class TargetStub
  bindSource: ->
  send: ->

class MessageStub
  copyWithTransformedPayload: ->

class QueryStub


describe 'Binding', ->

  beforeEach ->
    @source = new SourceStub
    @target = new TargetStub


  describe 'when bound', ->

    beforeEach ->
      @binding = new Binding({transform: (arg) -> arg})


    it 'should bind itself as target to its source', ->
      sinon.spy(@source, 'bindTarget')

      @binding.bindSourceTarget(@source, @target)

      expect(@source.bindTarget).to.have.been.calledWithSame(@binding)


    it 'should bind itself as source to its target', ->
      sinon.spy(@target, 'bindSource')

      @binding.bindSourceTarget(@source, @target)

      expect(@target.bindSource).to.have.been.calledWithSame(@binding)


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


  describe 'when enquired', ->

    beforeEach ->
      @binding = new Binding({})
      @binding.bindSourceTarget(@source, @target)


    it 'should send query to its source', ->
      @query = new QueryStub
      sinon.spy(@source, 'enquire')
      @binding.enquire(@query)

      expect(@source.enquire).to.have.been.calledWithSame(@query)
