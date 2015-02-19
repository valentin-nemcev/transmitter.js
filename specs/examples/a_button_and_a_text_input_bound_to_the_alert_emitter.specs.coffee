'use strict'


Message = require 'binder/message'
MessageSource = require 'binder/message/source'
MessageTarget = require 'binder/message/target'
Binder = require 'binder'


class Button

  getMessageSource: -> @messageSource ?= new MessageSource()

  click: ->
    @getMessageSource().send(Message.createBare())


class AlertEmitter

  getMessageTarget: -> @messageTarget ?= new MessageTarget(this)

  alert: ->

  receiveValue: (messageStr) -> @alert(messageStr)


class TextInput

  getMessageSource: -> @messageSource ?= new MessageSource()

  change: (value) ->
    @getMessageSource().send(Message.createValue(value))


describe 'Example: a button and a text input bound to the alert emitter', ->

  beforeEach ->
    @button = new Button()
    @textInput = new TextInput()
    @alertEmitter = new AlertEmitter()
    @alertEmitter.alert = sinon.spy()

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
