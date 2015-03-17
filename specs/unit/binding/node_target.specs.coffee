'use strict'


NodeTarget = require 'binder/binding/node_target'


class NodeStub

class SourceStub
  enquire: ->

class QueryStub

class MessageStub
  sendToNode: ->


describe 'NodeTarget', ->

  beforeEach ->
    @node = new NodeStub
    @target = new NodeTarget(@node)


  it 'delivers messages to its node', ->
    message = new MessageStub
    sinon.spy(message, 'sendToNode')

    @target.receive(message)

    expect(message.sendToNode).to.have.been.calledWithSame(@node)


  it 'sends queries to its source', ->
    @source = new SourceStub
    sinon.spy(@source, 'enquire')
    @target.bindSource(@source)
    @query = new QueryStub

    @target.enquire(@query)

    expect(@source.enquire).to.have.been.calledWithSame(@query)
