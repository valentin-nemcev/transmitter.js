'use strict'


Transmission = require 'transmitter/transmission/transmission'


class QueryStub
  respond: -> this
  shouldGetResponseAfter: -> no


describe 'Query queue', ->

  beforeEach ->
    @transmission = new Transmission()


  it 'responds to queries from nodes', ->
    @query = new QueryStub()
    sinon.spy(@query, 'respond')

    @transmission.enqueueQuery(@query)
    @transmission.respondToQueries()

    expect(@query.respond).to.have.been.calledOnce


  it 'responds to queries with lower order first', ->
    @query1 = new QueryStub()
    @query2 = new QueryStub()
    callOrder = []
    sinon.stub(@query1, 'shouldGetResponseAfter')
      .withArgs(sinon.match.same(@query2))
      .returns(no)
    sinon.stub(@query2, 'shouldGetResponseAfter')
      .withArgs(sinon.match.same(@query1))
      .returns(yes)
    sinon.stub(@query1, 'respond', -> callOrder.push 1)
    sinon.stub(@query2, 'respond', -> callOrder.push 2)

    @transmission.enqueueQuery(@query2)
    @transmission.enqueueQuery(@query1)
    @transmission.respondToQueries()

    expect(callOrder).to.deep.equal([1, 2])


  it 'responds to queries created as a result of previous response', ->
    @query1 = new QueryStub()
    @query2 = new QueryStub()
    sinon.stub(@query1, 'respond', =>
      @transmission.enqueueQuery(@query2)
    )
    sinon.spy(@query2, 'respond')

    @transmission.enqueueQuery(@query1)
    @transmission.respondToQueries()

    expect(@query2.respond).to.have.been.calledOnce
