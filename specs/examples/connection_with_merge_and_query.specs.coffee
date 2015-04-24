'use strict'


Transmitter = require 'transmitter'


class AlertEmitter extends Transmitter.Nodes.EventTarget

  alert: ->

  receiveValue: (messageStr) -> @alert(messageStr) if messageStr?


describe 'Connection with merge and query', ->

  beforeEach ->
    @button = new Transmitter.Nodes.EventSource()
    @textInput = new Transmitter.Nodes.Variable()
    @alertEmitter = new AlertEmitter()
    sinon.spy(@alertEmitter, 'alert')

    Transmitter.connection()
      .fromSource(@button)
      .fromSource(@textInput)
      .withTransform (payloads) =>
        payloads.get(@button)
          .replaceWhenPresent(payloads.get(@textInput).toValue())
      .toTarget @alertEmitter
      .connect()


  it 'should emit alert with text input value when button is clicked', ->
    Transmitter.updateNodeState(@textInput, 'Text input value')
    Transmitter.originate(@button, 'click')
    expect(@alertEmitter.alert).to.have.been.calledWith('Text input value')


  it 'should not emit alert when button is not clicked', ->
    Transmitter.updateNodeState(@textInput, 'Text input value')
    expect(@alertEmitter.alert).to.not.have.been.called
