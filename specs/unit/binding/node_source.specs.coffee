'use strict'


NodeSource = require 'binder/binding/node_source'


class TargetStub
  receive: ->

class NodeStub

class QueryStub
  enquireSourceNode: ->

class MessageStub


describe 'NodeSource', ->

  beforeEach ->
    @node = new NodeStub()
    @messageSource = new NodeSource(@node)


  it 'sends same message to multiple targets', ->
      @target1 = new TargetStub()
      @target2 = new TargetStub()
      @messageSource.bindTarget(@target1)
      @messageSource.bindTarget(@target2)
      sinon.spy(@target1, 'receive')
      sinon.spy(@target2, 'receive')
      message = new MessageStub

      @messageSource.sendMessage(message)

      expect(@target1.receive).to.have.been.calledWithSame(message)
      expect(@target2.receive).to.have.been.calledWithSame(message)


  it 'delivers queries to its node', ->
    @query = new QueryStub()
    sinon.spy(@query, 'enquireSourceNode')

    @messageSource.enquire(@query)

    expect(@query.enquireSourceNode)
      .to.have.been.calledWithSame(@node)
