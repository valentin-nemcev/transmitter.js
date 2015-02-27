'use strict'


Binder = require 'binder'


class Button
  Binder.extendWithMessageSender(this)

  click: -> Binder.sendBare(from: this)


class AlertEmitter
  Binder.extendWithMessageReceiver(this)

  alert: sinon.spy()

  receiveValue: (messageStr) -> @alert(messageStr)


describe 'Example: one-way binding', ->

  beforeEach ->
    @button = new Button()
    @alertEmitter = new AlertEmitter()

    Binder.buildOneWayBinding()
      .fromSource @button
      .toTarget @alertEmitter
      .withTransform (message) -> message.toValueMessage 'Button was clicked!'
      .bind()


  it 'should emit alert when button is clicked', ->
    @button.click()
    expect(@alertEmitter.alert).to.have.been.calledWith('Button was clicked!')
