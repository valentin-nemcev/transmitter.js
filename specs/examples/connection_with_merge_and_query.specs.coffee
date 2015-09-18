'use strict'


Transmitter = require 'transmitter'


class AlertEmitter extends Transmitter.Nodes.TargetNode

  alert: ->

  acceptPayload: (payload) ->
    payload.deliverValue(this)
    return this

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
        .inBackwardDirection()
        .withTransform ([buttonWasClicked, textValue]) =>
          if buttonWasClicked.get?
            textValue
          else
            Transmitter.Payloads.noop()
        .toTarget @alertEmitter
        .init(tr)


  it 'should emit alert with text input value when button is clicked', ->
    Transmitter.startTransmission (tr) =>
      @textInput.init(tr, 'Text input value')
    Transmitter.startTransmission (tr) =>
      @button.originate(tr, 'click')
    expect(@alertEmitter.alert).to.have.been.calledWith('Text input value')


  it 'should not emit alert when button is not clicked', ->
    Transmitter.startTransmission (tr) =>
      @textInput.init(tr, 'Text input value')
    expect(@alertEmitter.alert).to.not.have.been.called
