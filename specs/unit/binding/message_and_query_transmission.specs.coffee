'use strict'

NodeSource = require 'binder/binding/node_source'
NodeTarget = require 'binder/binding/node_target'
BindingBuilder = require 'binder/binding/one_way_builder'

Transmission = require 'binder/transmission/transmission'
Message = require 'binder/transmission/message'


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


  it 'transmits message from source to target', ->
    @transmission = new Transmission()
    @message = new Message(@transmission)

    @payload = new StubPayload()
    sinon.spy(@payload, 'deliver')
    @message.setPayload(@payload)

    @message.sendFromNode(@source)

    expect(@payload.deliver).to.have.been.calledWithSame(@target)
