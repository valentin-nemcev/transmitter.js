'use strict'


Message = require 'binder/message'
MessageSource = require 'binder/message/source'
MessageTarget = require 'binder/message/target'
Binding = require 'binder/binding'
CompositeBindingSource = require 'binder/binding/composite_source'
CompositeBindingSourcePart = require 'binder/binding/composite_source_part'


class Button

  constructor: ->
    @messageSource = new MessageSource()

  click: ->
    @messageSource.send(Message.createBare())


class AlertEmitter

  constructor: ->
    @messageTarget = new MessageTarget(this)

  alert: ->

  receiveValue: (messageStr) -> @alert(messageStr)


class TextInput

  constructor: ->
    @messageSource = new MessageSource()


  change: (value) ->
    @messageSource.send(Message.createValue(value))


describe 'Example: a button and a text input bound to the alert emitter', ->

  beforeEach ->
    @button = new Button()
    @textInput = new TextInput()
    @alertEmitter = new AlertEmitter()
    @alertEmitter.alert = sinon.spy()

    new Binding({
      source: new CompositeBindingSource([
        new CompositeBindingSourcePart(@button.messageSource, initiatesMerge: yes)
        new CompositeBindingSourcePart(@textInput.messageSource)
      ])
      target: @alertEmitter.messageTarget
      transform: (messages) =>
        messages.get(@textInput.messageSource)
    }).bind()


  it 'should emit alert with text input value when button is clicked', ->
    @textInput.change('Text input value')
    @button.click()
    expect(@alertEmitter.alert).to.have.been.calledWith('Text input value')


  it 'should not emit alert when button is not clicked', ->
    @textInput.change('Text input value')
    expect(@alertEmitter.alert).to.not.have.been.called
