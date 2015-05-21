'use strict'


Transmitter = require 'transmitter'


class AlertEmitter extends Transmitter.Nodes.TargetNode

  alert: ->

  receiveValue: (messageStr) -> @alert(messageStr) if messageStr?


describe 'Connection with merge and query', ->

  beforeEach ->
    @define 'button', new Transmitter.Nodes.SourceNode()
    @define 'textInput', new Transmitter.Nodes.Variable()
    @define 'alertEmitter', new AlertEmitter()
    sinon.spy(@alertEmitter, 'alert')

    Transmitter.startTransmission (tr) =>
      new Transmitter.Channels.SimpleChannel()
        .fromSource(@button)
        .fromSource(@textInput)
        .withTransform (payloads) =>
          payloads.fetch([@button, @textInput])
            .morph ([buttonWasClicked, textValue]) ->
              buttonWasClicked.flatMap -> textValue
        .toTarget @alertEmitter
        .connect(tr)


  it 'should emit alert with text input value when button is clicked', ->
    Transmitter.startTransmission (tr) =>
      @textInput.updateState('Text input value', tr)
    Transmitter.startTransmission (tr) =>
      @button.originate('click', tr)
    expect(@alertEmitter.alert).to.have.been.calledWith('Text input value')


  it 'should not emit alert when button is not clicked', ->
    Transmitter.startTransmission (tr) =>
      @textInput.updateState('Text input value', tr)
    expect(@alertEmitter.alert).to.not.have.been.called
