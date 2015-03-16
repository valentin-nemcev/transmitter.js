'use strict'


MessageSender = require 'binder/binding/sender'


class TargetStub
  send: ->

class NodeStub

class QueryStub
  enquireSourceNode: ->

class MessageStub


describe 'MessageSender', ->

  beforeEach ->
    @node = new NodeStub()
    @messageSource = new MessageSender(@node)

  describe 'with bound targets', ->

    beforeEach ->
      @target1 = new TargetStub()
      @target2 = new TargetStub()
      @messageSource.bindTarget(@target1)
      @messageSource.bindTarget(@target2)


    it 'should send message to bound targets', ->
      sinon.spy(@target1, 'send')
      sinon.spy(@target2, 'send')
      message = new MessageStub

      @messageSource.sendMessage(message)

      expect(@target1.send).to.have.been.calledWithSame(message)
      expect(@target2.send).to.have.been.calledWithSame(message)


  describe 'when enquired', ->

    it 'should pass its node to message', ->
      @query = new QueryStub()
      sinon.spy(@query, 'enquireSourceNode')

      @messageSource.enquire(@query)

      expect(@query.enquireSourceNode)
        .to.have.been.calledWithSame(@node)
