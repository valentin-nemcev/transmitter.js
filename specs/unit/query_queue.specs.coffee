'use strict'


Transmission = require 'transmitter/transmission/transmission'
Pass = require 'transmitter/transmission/pass'


class QueryStub
  constructor: (@pass) ->
  respond: -> @_didRespond = yes; this
  readyToRespond: -> not @_didRespond


class PointStub


describe 'Query queue', ->

  beforeEach ->
    @transmission = new Transmission()


  it 'responds to queries from nodes', ->
    @query = new QueryStub(Pass.getBackward())
    sinon.spy(@query, 'respond')

    @transmission.addCommunicationFor(@query, new PointStub())
    @transmission.respond()

    expect(@query.respond).to.have.been.calledOnce


  it 'responds to queries with lower pass priority first', ->
    @query1 = new QueryStub(Pass.getBackward())
    @query2 = new QueryStub(Pass.getForward())
    callOrder = []
    sinon.stub(@query1, 'respond', -> callOrder.push 1; @_didRespond = yes)
    sinon.stub(@query2, 'respond', -> callOrder.push 2; @_didRespond = yes)

    @transmission.addCommunicationFor(@query2, new PointStub())
    @transmission.addCommunicationFor(@query1, new PointStub())
    @transmission.respond()

    expect(callOrder).to.deep.equal([1, 2])


  it 'behaves like FIFO for queries with the same order', ->
    @query1 = new QueryStub(Pass.getBackward())
    @query2 = new QueryStub(Pass.getBackward())
    callOrder = []
    sinon.stub(@query1, 'respond', -> callOrder.push 1; @_didRespond = yes)
    sinon.stub(@query2, 'respond', -> callOrder.push 2; @_didRespond = yes)

    @transmission.addCommunicationFor(@query1, new PointStub())
    @transmission.addCommunicationFor(@query2, new PointStub())
    @transmission.respond()

    expect(callOrder).to.deep.equal([1, 2])


  it 'has option to reverse queries with the same order for testing', ->
    @query1 = new QueryStub(Pass.getBackward())
    @query2 = new QueryStub(Pass.getBackward())
    callOrder = []
    sinon.stub(@query1, 'respond', -> callOrder.push 1; @_didRespond = yes)
    sinon.stub(@query2, 'respond', -> callOrder.push 2; @_didRespond = yes)

    @transmission.reverseOrder = yes
    @transmission.addCommunicationFor(@query1, new PointStub())
    @transmission.addCommunicationFor(@query2, new PointStub())
    @transmission.respond()

    expect(callOrder).to.deep.equal([2, 1])


  it 'responds to queries created as a result of previous response', ->
    @query1 = new QueryStub(Pass.getBackward())
    @query2 = new QueryStub(Pass.getBackward())
    sinon.stub(@query1, 'respond', =>
      @transmission.addCommunicationFor(@query2, new PointStub())
      @query1._didRespond = yes
    )
    sinon.spy(@query2, 'respond')

    @transmission.addCommunicationFor(@query1, new PointStub())
    @transmission.respond()

    expect(@query2.respond).to.have.been.calledOnce
