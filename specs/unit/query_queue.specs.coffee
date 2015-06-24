'use strict'


Transmission = require 'transmitter/transmission/transmission'


class QueryStub
  respond: -> this
  getQueueOrder: ->


describe 'Query queue', ->

  beforeEach ->
    @transmission = new Transmission()


  it 'responds to queries from nodes', ->
    @query = new QueryStub()
    sinon.spy(@query, 'respond')

    @transmission.enqueueCommunication(@query)
    @transmission.respond()

    expect(@query.respond).to.have.been.calledOnce


  it 'responds to queries with lower order first', ->
    @query1 = new QueryStub()
    @query2 = new QueryStub()
    @query3 = new QueryStub()
    callOrder = []
    sinon.stub(@query1, 'getQueueOrder').returns([-1  , 0])
    sinon.stub(@query2, 'getQueueOrder').returns([-0.5, 0])
    sinon.stub(@query3, 'getQueueOrder').returns([-0.5, 1])
    sinon.stub(@query1, 'respond', -> callOrder.push 1)
    sinon.stub(@query2, 'respond', -> callOrder.push 2)
    sinon.stub(@query3, 'respond', -> callOrder.push 3)

    @transmission.enqueueCommunication(@query2)
    @transmission.enqueueCommunication(@query3)
    @transmission.enqueueCommunication(@query1)
    @transmission.respond()

    expect(callOrder).to.deep.equal([1, 2, 3])


  it 'responds to queries created as a result of previous response', ->
    @query1 = new QueryStub()
    @query2 = new QueryStub()
    sinon.stub(@query1, 'respond', =>
      @transmission.enqueueCommunication(@query2)
    )
    sinon.spy(@query2, 'respond')

    @transmission.enqueueCommunication(@query1)
    @transmission.respond()

    expect(@query2.respond).to.have.been.calledOnce
