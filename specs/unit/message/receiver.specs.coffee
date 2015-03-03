'use strict'


MessageReceiver = require 'binder/message/receiver'


class MessageStub
  sendToNode: ->

class NodeStub

class SourceStub
  enquire: ->

class QueryStub


describe 'MessageReceiver', ->

  beforeEach ->
    @node = new NodeStub
    @target = new MessageReceiver(@node)


  it 'should delegate to message when message is sent to it', ->
    message = new MessageStub
    sinon.spy(message, 'sendToNode')

    @target.send(message)

    expect(message.sendToNode).to.have.been.calledWithSame(@node)


  it 'should delegate to its source when enquired', ->
    @source = new SourceStub
    sinon.spy(@source, 'enquire')
    @target.bindSource(@source)
    @query = new QueryStub

    @target.enquire(@query)

    expect(@source.enquire).to.have.been.calledWithSame(@query)
