'use strict'

NodeSource = require 'transmitter/connection/node_source'
NodeTarget = require 'transmitter/connection/node_target'
Transmission = require 'transmitter/transmission/transmission'
Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'


class StubPayload
  deliver: ->

class NodeStub
  NodeSource.extend(this)
  NodeTarget.extend(this)
  getResponseMessage: ->

class SourceNodeStub
  NodeSource.extend(this)
  getResponseMessage: ->

class TargetNodeStub
  NodeTarget.extend(this)

class TargetStub
  receiveMessage: ->
  isConst: -> yes

class SourceStub
  receiveQuery: ->
  isConst: -> yes



describe 'Transmission cycles', ->

  beforeEach ->
    @transmission = new Transmission()


  describe 'with target node', ->

    beforeEach ->
      @targetNode = new TargetNodeStub()
      @source = new SourceStub()
      @targetNode.getNodeTarget().connectSource(@source)
      sinon.spy(@source, 'receiveQuery')

      @payload1 = new StubPayload()
      @payload2 = new StubPayload()
      sinon.spy(@payload2, 'deliver')


    specify 'second message should not be delivered', ->
      @message1 = new Message(@transmission, @payload1)
      @message2 = new Message(@transmission, @payload2)

      @message1.sendToTargetNode(@targetNode)
      @message2.sendToTargetNode(@targetNode)

      expect(@payload2.deliver).to.not.have.been.called


    specify 'query after message should not be sent', ->
      @message1 = new Message(@transmission, @payload1)
      @query2 = new Query(@transmission)

      @message1.sendToTargetNode(@targetNode)
      @query2.sendFromTargetNode(@targetNode)
      @transmission.respondToQueries()

      expect(@source.receiveQuery).to.not.have.been.called


    specify 'message after query should be sent', ->
      @query1 = new Query(@transmission)
      @message2 = new Message(@transmission, @payload2)

      @query1.sendFromTargetNode(@targetNode)
      @message2.sendToTargetNode(@targetNode)

      expect(@payload2.deliver).to.have.been.called


    specify 'second query should be sent', ->
      @query1 = new Query(@transmission)
      @query2 = new Query(@transmission)

      @query1.sendFromTargetNode(@targetNode)
      @query2.sendFromTargetNode(@targetNode)
      @transmission.respondToQueries()

      expect(@source.receiveQuery).to.have.been.calledTwice


  describe 'with source node', ->

    beforeEach ->
      @sourceNode = new SourceNodeStub()
      @target = new TargetStub()
      @sourceNode.getNodeSource().connectTarget(@target)
      sinon.spy(@target, 'receiveMessage')
      sinon.stub(@sourceNode, 'getResponseMessage', (sender) ->
        sender.createMessage(new StubPayload())
      )


    specify 'second message should not be sent', ->
      @message1 = new Message(@transmission, new StubPayload())
      @message2 = new Message(@transmission, new StubPayload())

      @message1.sendFromSourceNode(@sourceNode)
      @message2.sendFromSourceNode(@sourceNode)

      expect(@target.receiveMessage).to.have.been.calledOnce
      expect(@target.receiveMessage).to.have.been.calledWithSame(@message1)


    specify 'query after message should not be delivered', ->
      @message1 = new Message(@transmission, new StubPayload())
      @query2 = new Query(@transmission)

      @message1.sendFromSourceNode(@sourceNode)
      @query2.sendToSourceNode(@sourceNode)
      @transmission.respondToQueries()

      expect(@sourceNode.getResponseMessage).to.not.have.been.called


    specify 'second query should be delivered', ->
      @query1 = new Query(@transmission)
      @query2 = new Query(@transmission)

      @query1.sendToSourceNode(@sourceNode)
      @query2.sendToSourceNode(@sourceNode)
      @transmission.respondToQueries()

      expect(@sourceNode.getResponseMessage).to.have.been.calledTwice
