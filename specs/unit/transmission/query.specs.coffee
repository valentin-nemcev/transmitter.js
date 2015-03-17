'use strict'


Query = require 'binder/transmission/query'


class MessageChainStub
  addQueryTo: ->

class NodeTargetStub
  enquire: ->


describe 'Query', ->

  beforeEach ->
    @messageChain = new MessageChainStub()
    @query = new Query({@messageChain})


  describe 'when enquired target node', ->

    beforeEach ->
      @targetNodeTarget = new NodeTargetStub
      @targetNode = {getNodeTarget: => @targetNodeTarget}


    it 'should enquire node message target', ->
      sinon.spy(@targetNodeTarget, 'enquire')
      @query.enquireTargetNode(@targetNode)

      expect(@targetNodeTarget.enquire)
        .to.have.been.calledWithSame(@query)


  describe 'when enquired source node', ->

    it 'should add query to message chain', ->
      @node = new class NodeStub
      sinon.spy(@messageChain, 'addQueryTo')

      @query.enquireSourceNode(@node)

      expect(@messageChain.addQueryTo).to.have.been.calledWithSame(@node)
