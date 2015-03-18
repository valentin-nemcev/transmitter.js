'use strict'


Transmission = require 'binder/transmission/transmission'

Query = require 'binder/transmission/query'

class MessageStub

class NodeStub


describe 'Transmission', ->

  beforeEach ->
    @transmission = new Transmission()


  it 'creates queries', ->
    query = @transmission.createQuery()

    expect(query).to.be.instanceOf(Query)


  it 'should provide message sent from given node', ->
    @message1 = new MessageStub
    @message2 = new MessageStub
    @node1 = new NodeStub
    @node2 = new NodeStub

    @transmission.addMessageFrom(@message1, @node1)
    @transmission.addMessageFrom(@message2, @node2)

    expect(@transmission.getMessageFrom(@node1)).to.equal(@message1)
    expect(@transmission.getMessageFrom(@node2)).to.equal(@message2)


  it 'should add nodes to query queue', ->
    @node1 = new NodeStub
    @node2 = new NodeStub

    @transmission.addQueryTo(@node1)
    @transmission.addQueryTo(@node2)

    expect(@transmission.getEnqueriedNodes()).to.have.members([@node1, @node2])
