'use strict'

NodeSource = require 'binder/binding/node_source'
NodeTarget = require 'binder/binding/node_target'
BindingBuilder = require 'binder/binding/one_way_builder'

Transmission = require 'binder/transmission/transmission'


class NodeSourceStub
  NodeSource.extend(this)

class NodeTargetStub
  NodeTarget.extend(this)

class StubPayload
  deliver: ->


describe 'Message and query transmission', ->

  beforeEach ->
    @source = new NodeSourceStub
    @target = new NodeTargetStub

    new BindingBuilder()
      .fromSource @source
      .toTarget @target
      .bind()

    @transmission = new Transmission()


  it 'transmits message from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    @message = @transmission.createMessage(@payload)

    @message.sendFromSourceNode(@source)

    expect(@payload.deliver).to.have.been.calledWithSame(@target)


  it 'transmits query from source to target', ->
    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    @createStubPayload = sinon.stub()
    @createStubPayload
      .withArgs(sinon.match.same(@source))
      .returns(@payload)
    @query = @transmission.createQuery(@createStubPayload)

    @query.sendFromTargetNode(@target)
    @transmission.respondToQueries()

    expect(@payload.deliver).to.have.been.calledWithSame(@target)
