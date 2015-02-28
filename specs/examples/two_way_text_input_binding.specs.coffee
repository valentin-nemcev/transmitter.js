'use strict'


Binder = require 'binder'


class TextInput
  Binder.extendWithMessageSender(this)

  Binder.extendWithMessageReceiver(this)

  change: (value) -> Binder.sendValue(value, from: this)

  receiveValue: ->


class Variable
  Binder.extendWithMessageSender(this)

  Binder.extendWithMessageReceiver(this)

  update: (value) -> Binder.sendValue(value, from: this)

  receiveValue: ->


describe 'Example: Two-way text input binding', ->

  beforeEach ->
    @textInput = new TextInput()
    sinon.spy(@textInput, 'receiveValue')

    @originVariable = new Variable()
    sinon.spy(@originVariable, 'receiveValue')

    Binder.buildTwoWayBinding()
      .withOrigin @originVariable
      .withDerived @textInput
      .bind()


  it 'should send origin variable value to the text input after binding', ->
    expect(@textInput.receiveValue).to.have.been.calledWith('initial value')


  it 'should send origin variable update to the text input', ->
    @originVariable.update('updated value')
    expect(@textInput.receiveValue).to.have.been.calledWith('updated value')


  it 'should send text input update to the origin variable', ->
    @textInput.change('updated value')
    expect(@originVariable.receiveValue)
      .to.have.been.calledWith('updated value')
