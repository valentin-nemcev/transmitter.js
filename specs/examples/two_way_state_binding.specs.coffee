'use strict'


Binder = require 'binder'


class TextInput
  Binder.extendWithNodeSource(this)

  Binder.extendWithNodeTarget(this)

  change: (value) ->
    @setValue(value)
    Binder.sendNodeState(this)
    return this

  setValue: (@value) -> this

  getValue: -> @value


class Variable
  Binder.extendWithNodeSource(this)

  Binder.extendWithNodeTarget(this)

  getValue: -> @value

  setValue: (@value) -> this


describe 'Two-way state binding', ->

  beforeEach ->
    @textInput = new TextInput()

    @originVariable = new Variable()
    @originVariable.setValue('initial value')

    Binder.buildTwoWayBinding()
      .withOrigin @originVariable
      .withDerived @textInput
      .bind()


  it 'should send origin variable value to the text input after binding', ->
    expect(@textInput.getValue()).to.equal('initial value')


  it 'should send origin variable update to the text input', ->
    Binder.updateNodeState(@originVariable, 'updated value')
    expect(@textInput.getValue()).to.equal('updated value')


  it 'should send text input update to the origin variable', ->
    @textInput.change('updated value')
    expect(@originVariable.getValue()).to.equal('updated value')
