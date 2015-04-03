'use strict'


Transmitter = require 'transmitter'


class Button
  Transmitter.extendWithEventSource(this)

  click: -> Transmitter.originate(this, true)


class AlertEmitter
  Transmitter.extendWithEventTarget(this)

  alert: ->

  receiveValue: (messageStr) -> @alert(messageStr) if messageStr?


class TextInput
  Transmitter.extendWithStatefulNode(this)

  change: (value) ->
    @setValue(value)
    Transmitter.originate(this)
    return this

  setValue: (@value) -> this

  getValue: -> @value


describe 'Connection with merge and query', ->

  beforeEach ->
    @button = new Button()
    @textInput = new TextInput()
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
    @textInput.change('Text input value')
    @button.click()
    expect(@alertEmitter.alert).to.have.been.calledWith('Text input value')


  it 'should not emit alert when button is not clicked', ->
    @textInput.change('Text input value')
    expect(@alertEmitter.alert).to.not.have.been.called
