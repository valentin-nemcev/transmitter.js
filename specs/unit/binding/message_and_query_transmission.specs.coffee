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

    @message.sendFromNode(@source)

    expect(@payload.deliver).to.have.been.calledWithSame(@target)


  it 'transmits query from source to target', ->
    @query = @transmission.createQuery()
    sinon.spy(@transmission, 'addQueryTo')

    @query.sendFromNode(@target)

    expect(@transmission.addQueryTo).to.have.been.calledWith(
      sinon.match.same(@query), sinon.match.same(@source)
    )
