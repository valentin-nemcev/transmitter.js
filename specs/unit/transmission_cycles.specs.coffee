'use strict'

SourceNode = require 'transmitter/nodes/source_node'
TargetNode = require 'transmitter/nodes/target_node'
RelayNode = require 'transmitter/nodes/relay_node'
Transmission = require 'transmitter/transmission/transmission'
Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'


class StubPayload
  deliver: ->

class NodeStub extends RelayNode

class SourceNodeStub extends SourceNode
  inspect: -> '[SourceNodeStub]'

  createResponsePayload: -> new StubPayload()


class TargetNodeStub extends TargetNode

  inspect: -> '[TargetNodeStub]'

  createResponsePayload: -> new StubPayload()

  acceptPayload: (payload) ->
    payload.deliver(this)
    return this


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
      sinon.spy(@targetNode, 'routeMessage')
      @source = new SourceStub()
      @targetNode.getNodeTarget().connectSource(@source)
      sinon.spy(@source, 'receiveQuery')

      @payload1 = new StubPayload()
      @payload2 = new StubPayload()


    specify 'second message should not be delivered', ->
      @message1 = new Message(@transmission, @payload1)
      @message2 = new Message(@transmission, @payload2)

      @message1.sendToNodeTarget(@targetNode.getNodeTarget())
      @message2.sendToNodeTarget(@targetNode.getNodeTarget())

      expect(@targetNode.routeMessage).to.have.been.calledOnce
      expect(@targetNode.routeMessage)
        .to.have.been.calledWith(sinon.match.any, sinon.match.same(@payload1))


    specify 'query after message should not be sent', ->
      @message1 = new Message(@transmission, @payload1)
      @query2 = new Query(@transmission)

      @message1.sendToNodeTarget(@targetNode.getNodeTarget())
      @query2.sendToNodeTarget(@targetNode.getNodeTarget())
      @transmission.respondToQueries()

      expect(@source.receiveQuery).to.not.have.been.called


    specify 'message after query should be sent', ->
      @query1 = new Query(@transmission)
      @message2 = new Message(@transmission, @payload2)

      @query1.sendToNodeTarget(@targetNode.getNodeTarget())
      @message2.sendToNodeTarget(@targetNode.getNodeTarget())

      expect(@targetNode.routeMessage)
        .to.have.been.calledWith(sinon.match.any, sinon.match.same(@payload2))


    specify 'second query should be sent', ->
      @query1 = new Query(@transmission)
      @query2 = new Query(@transmission)

      @query1.sendToNodeTarget(@targetNode.getNodeTarget())
      @query2.sendToNodeTarget(@targetNode.getNodeTarget())
      @transmission.respondToQueries()

      expect(@source.receiveQuery).to.have.been.calledTwice


  describe 'with source node', ->

    beforeEach ->
      @sourceNode = new SourceNodeStub()
      @target = new TargetStub()
      @sourceNode.getNodeSource().connectTarget(@target)
      sinon.spy(@target, 'receiveMessage')
      sinon.spy(@sourceNode, 'createResponsePayload')


    specify 'second message should not be sent', ->
      @message1 = new Message(@transmission, new StubPayload())
      @message2 = new Message(@transmission, new StubPayload())

      @message1.sendToNodeSource(@sourceNode.getNodeSource())
      @message2.sendToNodeSource(@sourceNode.getNodeSource())

      expect(@target.receiveMessage).to.have.been.calledOnce
      expect(@target.receiveMessage).to.have.been.calledWithSame(@message1)


    specify 'query after message should not be delivered', ->
      @message1 = new Message(@transmission, new StubPayload())
      @query2 = new Query(@transmission)

      @message1.sendToNodeSource(@sourceNode.getNodeSource())
      @query2.sendToNodeSource(@sourceNode.getNodeSource())
      @transmission.respondToQueries()

      expect(@sourceNode.createResponsePayload).to.not.have.been.called


    specify 'second query should be delivered', ->
      @query1 = new Query(@transmission)
      @query2 = new Query(@transmission)

      @query1.sendToNodeSource(@sourceNode.getNodeSource())
      @query2.sendToNodeSource(@sourceNode.getNodeSource())
      @transmission.respondToQueries()

      expect(@sourceNode.createResponsePayload).to.have.been.calledTwice
