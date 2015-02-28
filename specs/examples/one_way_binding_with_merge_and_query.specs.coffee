'use strict'


Binder = require 'binder'


class Button
  Binder.extendWithMessageSender(this)

  click: -> Binder.sendBare(from: this)


class AlertEmitter
  Binder.extendWithMessageReceiver(this)

  alert: ->

  receiveValue: (messageStr) -> @alert(messageStr)


class TextInput
  Binder.extendWithMessageSender(this)

  change: (value) -> Binder.sendValue(value, from: this)


describe 'Example: one-way binding with merge and query', ->

  beforeEach ->
    @button = new Button()
    @textInput = new TextInput()
    @alertEmitter = new AlertEmitter()
    sinon.spy(@alertEmitter, 'alert')

    Binder.buildOneWayBinding()
      .fromSource(
        Binder.buildCompositeSource()
          .withPart @button
          .withPassivePart @textInput
          .withMerge (messages) => messages.get(@textInput)
      )
      .toTarget @alertEmitter
      .bind()


  it 'should emit alert with text input value when button is clicked', ->
    @textInput.change('Text input value')
    @button.click()
    expect(@alertEmitter.alert).to.have.been.calledWith('Text input value')


  it 'should not emit alert when button is not clicked', ->
    @textInput.change('Text input value')
    expect(@alertEmitter.alert).to.not.have.been.called
