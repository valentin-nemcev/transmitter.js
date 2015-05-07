'use strict'


Transmitter = require 'transmitter'


class AlertEmitter extends Transmitter.Nodes.EventTarget

  alert: ->

  receiveValue: (messageStr) -> @alert(messageStr) if messageStr?


describe 'Connection with merge and query', ->

  beforeEach ->
    @define 'button', new Transmitter.Nodes.EventSource()
    @define 'textInput', new Transmitter.Nodes.Variable()
    @define 'alertEmitter', new AlertEmitter()
    sinon.spy(@alertEmitter, 'alert')

    Transmitter.startTransmission (sender) =>
      new Transmitter.Channels.EventChannel()
        .fromSource(@button)
        .fromSource(@textInput)
        .withTransform (payloads) =>
          payloads.get(@button)
            .replaceWhenPresent(payloads.get(@textInput).toValue())
        .toTarget @alertEmitter
        .connect(sender)


  it 'should emit alert with text input value when button is clicked', ->
    Transmitter.startTransmission (sender) =>
      @textInput.updateState('Text input value', sender)
    Transmitter.startTransmission (sender) =>
      @button.originate('click', sender)
    expect(@alertEmitter.alert).to.have.been.calledWith('Text input value')


  it 'should not emit alert when button is not clicked', ->
    Transmitter.startTransmission (sender) =>
      @textInput.updateState('Text input value', sender)
    expect(@alertEmitter.alert).to.not.have.been.called
