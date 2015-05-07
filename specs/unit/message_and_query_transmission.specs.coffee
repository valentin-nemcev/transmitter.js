'use strict'

NodeSource = require 'transmitter/connection/node_source'
NodeTarget = require 'transmitter/connection/node_target'
SimplexChannel = require 'transmitter/channels/simplex_channel'

Message = require 'transmitter/transmission/message'
Query = require 'transmitter/transmission/query'
Transmission = require 'transmitter/transmission/transmission'

Transmitter = require 'transmitter'


class StubPayload
  deliver: ->

class NodeSourceStub
  NodeSource.extend(this)

  routeQuery: (query) ->
    query.completeRouting(this)
    return this

  respondToQuery: (sender) ->
    sender.createMessage(new StubPayload()).sendToNodeSource(@getNodeSource())
    return this


class NodeTargetStub
  NodeTarget.extend(this)
  routeMessage: -> return this


describe 'Message and query transmission', ->

  beforeEach ->
    @source = new NodeSourceStub()
    @target = new NodeTargetStub()

    Transmitter.startTransmission (sender) =>
      new SimplexChannel()
        .fromSource @source
        .toTarget @target
        .connect(sender)

    @transmission = new Transmission()


  it 'transmits message from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@target, 'routeMessage')
    @message = new Message(@transmission, @payload)

    @message.sendToNodeSource(@source.getNodeSource())

    expect(@target.routeMessage).to.have.been
      .calledWith(sinon.match.same(@payload))


  it 'transmits query from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@target, 'routeMessage')
    sinon.stub(@source, 'respondToQuery', (sender) =>
      sender.createMessage(@payload).sendToNodeSource(@source.getNodeSource())
    )
    @query = new Query(@transmission)

    @query.sendToNodeTarget(@target.getNodeTarget())
    @transmission.respondToQueries()

    expect(@target.routeMessage).to.have.been
      .calledWith(sinon.match.same(@payload))
