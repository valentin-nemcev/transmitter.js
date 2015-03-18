'use strict'


Query = require 'binder/transmission/query'


class TransmissionStub
  addQueryTo: ->

class NodeTargetStub
  enquire: ->


describe 'Query', ->

  beforeEach ->
    @transmission = new TransmissionStub()
    @query = new Query({@transmission})


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

    it 'should add query to transmission', ->
      @node = new class NodeStub
      sinon.spy(@transmission, 'addQueryTo')

      @query.enquireSourceNode(@node)

      expect(@transmission.addQueryTo).to.have.been.calledWithSame(@node)
