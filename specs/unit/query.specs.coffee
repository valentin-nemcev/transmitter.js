'use strict'


Query = require 'binder/query'


class MessageChainStub
  addQueryTo: ->

class MessageReceiverStub
  enquire: ->


describe 'Query', ->

  beforeEach ->
    @messageChain = new MessageChainStub()
    @query = new Query({@messageChain})


  describe 'when enquired target node', ->

    beforeEach ->
      @targetMessageReceiver = new MessageReceiverStub
      @targetNode = {getMessageReceiver: => @targetMessageReceiver}


    it 'should enquire node message target', ->
      sinon.spy(@targetMessageReceiver, 'enquire')
      @query.enquireTargetNode(@targetNode)

      expect(@targetMessageReceiver.enquire)
        .to.have.been.calledWithSame(@query)


  describe 'when enquired source node', ->

    it 'should add query to message chain', ->
      @node = new class NodeStub
      sinon.spy(@messageChain, 'addQueryTo')

      @query.enquireSourceNode(@node)

      expect(@messageChain.addQueryTo).to.have.been.calledWithSame(@node)
